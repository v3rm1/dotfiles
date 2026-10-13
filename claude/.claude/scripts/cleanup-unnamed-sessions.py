#!/usr/bin/env python3
"""Delete Claude Code session transcripts that have no custom title
(never renamed via /rename) and have not been modified in 7+ days.

Runs as a SessionStart hook, globally across all projects under
~/.claude/projects/. Named sessions (customTitle set) are never touched,
regardless of age. Logs every deletion to cleanup-unnamed-sessions.log
next to this script for auditability.
"""

import glob
import json
import os
import shutil
import sys
import time

STALE_SECONDS = 7 * 86400
PROJECTS_GLOB = os.path.expanduser("~/.claude/projects/*/*.jsonl")
LOG_PATH = os.path.join(os.path.dirname(os.path.abspath(__file__)), "cleanup-unnamed-sessions.log")

try:
    current_session_id = json.load(sys.stdin).get("session_id")
except Exception:
    current_session_id = None

cutoff = time.time() - STALE_SECONDS
deleted = []

for jsonl_path in glob.glob(PROJECTS_GLOB):
    session_id = os.path.basename(jsonl_path)[: -len(".jsonl")]
    if session_id == current_session_id:
        continue
    try:
        if os.path.getmtime(jsonl_path) >= cutoff:
            continue
        with open(jsonl_path, "r") as f:
            first_line = f.readline()
        title = json.loads(first_line).get("customTitle")
    except Exception:
        continue
    if title:
        continue

    sidecar_dir = os.path.join(os.path.dirname(jsonl_path), session_id)
    try:
        os.remove(jsonl_path)
        if os.path.isdir(sidecar_dir):
            shutil.rmtree(sidecar_dir, ignore_errors=True)
        deleted.append(jsonl_path)
    except OSError:
        continue

if deleted:
    with open(LOG_PATH, "a") as log:
        log.write(f"{time.strftime('%Y-%m-%d %H:%M:%S')} deleted {len(deleted)} stale unnamed session(s):\n")
        for path in deleted:
            log.write(f"  {path}\n")
