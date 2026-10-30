"""Fade kitty's glass background when its window loses focus (macOS only).

omniwm cannot fade unfocused windows, so kitty does it itself here. On niri the
compositor already does this through niri/.config/niri/glass.kdl, so the
watcher does nothing on Linux.
"""
from kitty.constants import is_macos

FOCUSED = "0.75"
UNFOCUSED = "0.65"


def on_focus_change(boss, window, data):
    if not is_macos:
        return
    opacity = FOCUSED if data["focused"] else UNFOCUSED
    boss.call_remote_control(window, ("set-background-opacity", f"--match=id:{window.id}", opacity))
