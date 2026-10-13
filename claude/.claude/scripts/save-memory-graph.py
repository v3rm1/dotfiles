#!/usr/bin/env python3
import json
import sys
import os
import shutil
import subprocess
import re
from datetime import datetime
from pathlib import Path

MEMORY_DIR = Path.home() / "Documents/obsidian-files/obsidian-dashboard/agent_memory"
INDEX_FILE = MEMORY_DIR / "_INDEX.md"
CLAUDE_BIN = shutil.which("claude") or "claude"
CHILD_ENV = "MEMORY_GRAPH_CHILD"
TODAY = datetime.now().strftime("%Y-%m-%d")


AGY_BRAIN = Path.home() / ".gemini/antigravity-cli/brain"


def read_transcript(hook_input: dict) -> list[dict]:
    # Claude Code uses snake_case; Antigravity uses camelCase
    transcript_path = (
        hook_input.get("transcript_path")
        or hook_input.get("transcriptPath")
        or ""
    )
    # Antigravity fallback: derive path from conversationId
    if not transcript_path:
        conv_id = hook_input.get("conversationId", "")
        if conv_id:
            candidate = AGY_BRAIN / conv_id / ".system_generated/logs/transcript.jsonl"
            if candidate.exists():
                transcript_path = str(candidate)
    if transcript_path and Path(transcript_path).exists():
        lines = Path(transcript_path).read_text().strip().split("\n")
        turns = []
        for line in lines[-60:]:
            try:
                turns.append(json.loads(line))
            except Exception:
                pass
        return turns
    return []


def turns_to_text(turns: list[dict]) -> str:
    messages = []
    for turn in turns:
        # Antigravity format: source + type + content fields
        if "source" in turn or "step_index" in turn:
            source = turn.get("source", "")
            content = turn.get("content", "") or ""
            if not isinstance(content, str):
                content = str(content)
            role = "user" if source == "USER_EXPLICIT" else "assistant" if source == "MODEL" else ""
            if content and role:
                messages.append(f"{role}: {content[:600]}")
        else:
            # Claude Code format: role + content fields
            role = turn.get("role", "")
            content = turn.get("content", "")
            if isinstance(content, list):
                parts = [
                    c.get("text", "")
                    for c in content
                    if isinstance(c, dict) and c.get("type") == "text"
                ]
                content = " ".join(parts)
            if content and role in ("user", "assistant"):
                messages.append(f"{role}: {str(content)[:600]}")
    return "\n".join(messages[-24:])


def extract_via_claude(transcript_text: str) -> dict | None:
    prompt = f"""Analyze this Claude Code conversation transcript and extract memory graph nodes.

TRANSCRIPT:
{transcript_text}

Output ONLY valid JSON — no markdown fences, no explanation — with this exact structure:
{{
  "topics": [{{"name": "kebab-case-name", "desc": "one sentence", "points": ["key insight 1", "key insight 2"]}}],
  "entities": [{{"name": "kebab-case-name", "desc": "one sentence", "type": "person|project|tool|concept"}}],
  "decisions": ["decision or conclusion reached"],
  "summary": "Two sentence summary of what was accomplished.",
  "links": [["node-a", "node-b"]]
}}

Rules:
- topics: substantive concepts discussed, max 5, skip trivial chit-chat
- entities: recurring nouns (tools, people, projects, frameworks), max 5
- links: pairs of nodes that are meaningfully related
- If the conversation is too short or trivial, output: {{"topics":[],"entities":[],"decisions":[],"summary":"","links":[]}}
"""
    try:
        # CHILD_ENV stops the nested claude's own hooks from re-running this script
        result = subprocess.run(
            [CLAUDE_BIN, "-p", "--model", "haiku", prompt],
            capture_output=True, text=True, timeout=90,
            env={**os.environ, CHILD_ENV: "1"},
        )
        return parse_json(result.stdout.strip())
    except Exception as e:
        print(f"[memory-graph] claude extract failed: {e}", file=sys.stderr)
        return None


def parse_json(text: str) -> dict | None:
    start = text.find('{')
    end = text.rfind('}')
    if start != -1 and end != -1 and end > start:
        try:
            return json.loads(text[start:end+1])
        except Exception:
            pass
    return None


def node_path(name: str) -> Path:
    return MEMORY_DIR / f"{name}.md"


def write_or_update_node(name: str, data: dict, node_type: str) -> None:
    p = node_path(name)
    desc = data.get("desc", "")
    session_line = f"- {TODAY}: {desc}"

    if p.exists():
        text = p.read_text()
        text = re.sub(r'updated: \d{4}-\d{2}-\d{2}', f'updated: {TODAY}', text)
        if "## Sessions\n" in text:
            text = text.replace("## Sessions\n", f"## Sessions\n{session_line}\n", 1)
        else:
            text = text.rstrip() + f"\n\n## Sessions\n{session_line}\n"
        p.write_text(text)
    else:
        points = data.get("points", [])
        points_md = "\n".join(f"- {pt}" for pt in points) if points else "- (none yet)"
        title = name.replace("-", " ").title()
        p.write_text(
            f"---\n"
            f"tags: [agent-memory, {node_type}]\n"
            f"created: {TODAY}\n"
            f"updated: {TODAY}\n"
            f"---\n\n"
            f"# {title}\n\n"
            f"{desc}\n\n"
            f"## Key Points\n{points_md}\n\n"
            f"## Sessions\n{session_line}\n\n"
            f"## Related\n"
        )


def add_links(links: list[list[str]]) -> None:
    for pair in links:
        if len(pair) != 2:
            continue
        a, b = pair
        for node_name, other in [(a, b), (b, a)]:
            p = node_path(node_name)
            if p.exists():
                text = p.read_text()
                link = f"[[{other}]]"
                if link not in text:
                    if "## Related\n" in text:
                        text = text.replace("## Related\n", f"## Related\n{link} ")
                    else:
                        text = text.rstrip() + f"\n\n## Related\n{link}\n"
                    p.write_text(text)


def update_index(extracted: dict) -> None:
    if not INDEX_FILE.exists():
        INDEX_FILE.write_text(
            f"# Agent Memory Index\nUpdated: {TODAY}\n\n## Topics\n\n## Entities\n\n## Recent Sessions\n"
        )

    index = INDEX_FILE.read_text()

    # Update date header
    index = re.sub(r'Updated: \d{4}-\d{2}-\d{2}', f'Updated: {TODAY}', index)

    # Prepend session to Recent Sessions
    summary = extracted.get("summary", "").replace("\n", " ")[:120]
    if summary:
        session_entry = f"- {TODAY}: {summary}"
        if "## Recent Sessions\n" in index:
            parts = index.split("## Recent Sessions\n", 1)
            existing = [
                s for s in parts[1].strip().split("\n") if s.startswith("-")
            ][:9]
            index = parts[0] + "## Recent Sessions\n" + "\n".join(
                [session_entry] + existing
            ) + "\n"

    # Add topics not already in index
    for topic in extracted.get("topics", []):
        entry = f"- [[{topic['name']}]] {topic['desc']}"
        if f"[[{topic['name']}]]" not in index:
            index = index.replace("## Topics\n", f"## Topics\n{entry}\n", 1)

    # Add entities not already in index
    for entity in extracted.get("entities", []):
        entry = f"- [[{entity['name']}]] {entity['desc']}"
        if f"[[{entity['name']}]]" not in index:
            index = index.replace("## Entities\n", f"## Entities\n{entry}\n", 1)

    INDEX_FILE.write_text(index)


def main() -> None:
    if os.environ.get(CHILD_ENV):
        print("{}")
        return

    try:
        raw = sys.stdin.read()
        hook_input = json.loads(raw) if raw.strip() else {}
    except Exception:
        hook_input = {}

    turns = read_transcript(hook_input)
    if not turns:
        print("{}")
        return

    transcript_text = turns_to_text(turns)
    if len(transcript_text) < 120:
        print("{}")
        return

    extracted = extract_via_claude(transcript_text)
    if not extracted or not extracted.get("summary"):
        print("{}")
        return

    MEMORY_DIR.mkdir(parents=True, exist_ok=True)

    for topic in extracted.get("topics", []):
        if topic.get("name"):
            write_or_update_node(topic["name"], topic, "topic")

    for entity in extracted.get("entities", []):
        if entity.get("name"):
            write_or_update_node(entity["name"], entity, entity.get("type", "entity"))

    add_links(extracted.get("links", []))
    update_index(extracted)
    # Antigravity Stop hook requires JSON on stdout; empty object = allow stop
    print("{}")


if __name__ == "__main__":
    try:
        main()
    except Exception as e:
        print(f"[memory-graph] fatal: {e}", file=sys.stderr)
        print("{}")
