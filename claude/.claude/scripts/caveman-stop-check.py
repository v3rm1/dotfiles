#!/usr/bin/env python3
"""Stop hook: warn when the final reply drifts out of caveman style.

Reads the Stop hook payload on stdin, extracts the last assistant message (from
`last_assistant_message`, else the transcript), strips code, tables and warning
blocks, then scores the remaining prose. Blockquotes (quoted third-party text such
as messages drafted for someone else) are exempt too. On failure it prints a JSON
`{"systemMessage": ...}` so the user sees a warning. It is warn-only: it never
blocks the turn, because forced rewrites showed the user duplicate replies.

Usage as a checker: caveman-stop-check.py --text FILE  (prints score, exit 1 on fail)
"""

import json
import re
import sys

MIN_WORDS = 30          # short replies are never checked
MAX_ARTICLE_RATIO = 0.06  # 3.5% blocked nearly every reply; duplicate output costs more than mild drift
MAX_FILLER = 1
MAX_LINE_WORDS = 32     # a single prose line longer than this is a paragraph, not a fragment

ARTICLES = {"the", "a", "an"}
FILLER = {
    "just", "really", "basically", "actually", "simply", "certainly", "sure",
    "happy", "of course", "i'll", "let me", "i've", "i'm", "great", "please note",
}


def strip_exempt(text: str) -> str:
    text = re.sub(r"```.*?```", " ", text, flags=re.S)
    text = re.sub(r"`[^`]*`", " ", text)
    text = re.sub(r"https?://\S+", " ", text)
    warning = re.compile(r"\s*(?:>\s*)?(?:[-*+]\s+|\d+\.\s+)?\*\*(warning|caution|danger)", flags=re.I)
    kept = []
    for para in re.split(r"\n\s*\n", text):
        # auto-clarity exception: security / irreversible-action warnings may use full
        # prose, whether the paragraph or just a bullet inside it carries the marker
        if re.match(r"\s*(>\s*)?\*\*(warning|caution|danger)", para, flags=re.I):
            continue
        kept.extend(
            line for line in para.splitlines()
            if not line.lstrip().startswith(("|", ">")) and not warning.match(line)
        )
    return "\n".join(kept)


def score(text: str) -> dict:
    prose = strip_exempt(text)
    words = re.findall(r"[A-Za-z']+", prose.lower())
    joined = " ".join(words)
    long_lines = [
        line.strip()[:60]
        for line in prose.splitlines()
        if len(re.findall(r"[A-Za-z']+", line)) > MAX_LINE_WORDS
    ]
    filler_hits = sorted(
        f for f in FILLER if re.search(rf"(?<![a-z']){re.escape(f)}(?![a-z'])", joined)
    )
    n = len(words)
    ratio = sum(w in ARTICLES for w in words) / n if n else 0.0
    problems = []
    if n >= MIN_WORDS:
        if ratio > MAX_ARTICLE_RATIO:
            problems.append(f"article ratio {ratio:.1%} > {MAX_ARTICLE_RATIO:.1%}")
        if len(filler_hits) > MAX_FILLER:
            problems.append(f"filler words: {', '.join(filler_hits)}")
        if long_lines:
            problems.append(f"{len(long_lines)} prose line(s) over {MAX_LINE_WORDS} words, e.g. \"{long_lines[0]}...\"")
    return {"words": n, "article_ratio": round(ratio, 4), "filler": filler_hits, "problems": problems}


def last_assistant_text(payload: dict) -> str:
    if payload.get("last_assistant_message"):
        return payload["last_assistant_message"]
    path = payload.get("transcript_path")
    if not path:
        return ""
    text = ""
    with open(path, encoding="utf-8") as f:
        for line in f:
            try:
                entry = json.loads(line)
            except json.JSONDecodeError:
                continue
            msg = entry.get("message") or {}
            if entry.get("type") != "assistant" or msg.get("role") != "assistant":
                continue
            content = msg.get("content")
            parts = [c.get("text", "") for c in content if c.get("type") == "text"] if isinstance(content, list) else [content or ""]
            if any(p.strip() for p in parts):
                text = "\n".join(parts)
    return text


def main() -> int:
    if len(sys.argv) == 3 and sys.argv[1] == "--text":
        result = score(open(sys.argv[2], encoding="utf-8").read())
        print(json.dumps(result))
        return 1 if result["problems"] else 0

    payload = json.load(sys.stdin)
    if payload.get("stop_hook_active"):
        return 0
    result = score(last_assistant_text(payload))
    if result["problems"]:
        print(json.dumps({
            "systemMessage": "Caveman drift: " + "; ".join(result["problems"]),
        }))
    return 0


if __name__ == "__main__":
    sys.exit(main())
