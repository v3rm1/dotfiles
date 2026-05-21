#!/bin/zsh
# Skip if already inside tmux
[ -n "$TMUX" ] && exec $SHELL

TMUX=/opt/homebrew/bin/tmux

if ! $TMUX list-sessions &>/dev/null; then
    # No sessions — create default
    exec $TMUX new-session -s main
fi

SESSION_COUNT=$($TMUX list-sessions | wc -l | tr -d ' ')

if [ "$SESSION_COUNT" -eq 1 ]; then
    # One session — attach directly
    exec $TMUX attach
else
    # Multiple sessions — show picker
    exec $TMUX choose-tree -Zs
fi
