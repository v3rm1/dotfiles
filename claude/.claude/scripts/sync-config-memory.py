#!/usr/bin/env python3
"""Replace one fenced code block in a claude-sync memory doc with a source file's live content.

Used by the CLAUDE.md/GEMINI.md/settings.json -> agent_memory/claude-sync PostToolUse hooks.
"""
import argparse
import re
import sys


def main() -> int:
    p = argparse.ArgumentParser()
    p.add_argument("--target", required=True, help="memory .md file to update")
    p.add_argument("--heading", required=True, help="exact heading line preceding the fenced block")
    p.add_argument("--source", required=True, help="file whose current content replaces the block")
    p.add_argument("--lang", default="", help="fence language tag, e.g. json (default: none)")
    args = p.parse_args()

    with open(args.source, encoding="utf-8") as f:
        new_content = f.read().rstrip("\n")

    with open(args.target, encoding="utf-8") as f:
        doc = f.read()

    heading_idx = doc.find(args.heading)
    if heading_idx == -1:
        print(f"heading not found in {args.target}: {args.heading!r}", file=sys.stderr)
        return 1

    fence_start = doc.find("```", heading_idx)
    if fence_start == -1:
        print(f"no fenced block after heading in {args.target}", file=sys.stderr)
        return 1
    fence_end = doc.find("```", fence_start + 3)
    fence_end = doc.find("```", fence_end + 3) if doc[fence_start:fence_start + 6].strip("`") == "" else fence_end
    # locate the closing ``` that matches the opening fence
    open_line_end = doc.find("\n", fence_start)
    close_start = doc.find("\n```", open_line_end)
    if close_start == -1:
        print(f"unterminated fenced block in {args.target}", file=sys.stderr)
        return 1

    new_doc = doc[: open_line_end + 1] + new_content + doc[close_start:]
    with open(args.target, "w", encoding="utf-8") as f:
        f.write(new_doc)
    print(f"synced {args.source} -> {args.target}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
