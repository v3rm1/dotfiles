#!/usr/bin/python3
"""Send new windows to their app rule's workspace.

OmniWM only honours an app rule's assignToWorkspace when the app has no
tracked windows yet. Apps that open a splash or updater window first
(Discord, Teams, ...) therefore get their real window on whatever workspace
is active. This watches OmniWM's window inventory and moves each newly
appearing tiled window to its rule's workspace.

Only windows that appear while this runs are touched: windows present in the
first snapshot, floating windows (splash screens) and windows moved by hand
later are left alone. Needs ipcEnabled = true in settings.toml. Run by the
com.github.v3rm1.omniwm-rule-watcher launch agent.
"""

import json
import subprocess
import sys

CTL = "/opt/homebrew/bin/omniwmctl"


def workspace_rules():
    """bundle id -> workspace name, from the first rule (by position) that sets one."""
    out = subprocess.run([CTL, "query", "rules", "--format", "json"], capture_output=True, text=True)
    rules = json.loads(out.stdout)["result"]["payload"]["rules"]
    mapping = {}
    for rule in sorted(rules, key=lambda r: r.get("position", 0)):
        ws = rule.get("assignToWorkspace")
        if ws and rule.get("isValid", True) and rule.get("bundleId"):
            mapping.setdefault(rule["bundleId"], ws)
    return mapping


def main():
    proc = subprocess.Popen(
        [CTL, "subscribe", "windows-changed", "--reconnect", "--format", "ndjson"],
        stdout=subprocess.PIPE,
        text=True,
    )
    seen = None  # window ids already known; None until the first snapshot
    for line in proc.stdout:
        event = json.loads(line)
        if event.get("kind") != "event":
            continue
        windows = event["result"]["payload"]["windows"]
        ids = {w["id"] for w in windows}
        if seen is None:
            seen = ids
            continue
        new = [w for w in windows if w["id"] not in seen]
        seen = ids
        if not new:
            continue
        rules = workspace_rules()
        for w in new:
            target = rules.get(w["app"].get("bundleId", ""))
            if not target or w["mode"] != "tiling" or w["workspace"]["rawName"] == target:
                continue
            subprocess.run([CTL, "window", "move-to-workspace", w["id"], target], capture_output=True)
            print(f"moved {w['app'].get('name')} '{w['title']}' -> {target}", flush=True)
    return proc.wait()


if __name__ == "__main__":
    sys.exit(main())
