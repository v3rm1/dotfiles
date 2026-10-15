#!/usr/bin/env bash
# tmux session picker: live sessions + fd-listed dirs, fzf-picked, attach or create.
set -euo pipefail

# only hide the current session when inside tmux; outside, display-message
# still returns the most recent session and would wrongly filter it out
cur=""
[ -n "${TMUX:-}" ] && cur=$(tmux display-message -p '#S' 2>/dev/null || true)

{
    tmux list-sessions -F '#S' 2>/dev/null | grep -v "^${cur}\$" | sed 's/^/[session] /' || true
    # live listing each open, so new dirs show up without any index
    fd -t d -d 1 . "$HOME" "$HOME/Downloads" 2>/dev/null || true
    fd -t d -d 3 . "$HOME/Documents" 2>/dev/null || true
} | sed 's:/$::' | fzf --no-sort --ansi --border-label ' sesh ' \
    --preview 'n={}; n=${n#\[session\] }; tmux has-session -t "$n" 2>/dev/null && tmux capture-pane -ept "$n" || eza -1 --color=always "$n" 2>/dev/null || ls "$n"' \
    > /tmp/tmux-sesh-pick

raw=$(cat /tmp/tmux-sesh-pick)
rm -f /tmp/tmux-sesh-pick
[ -z "$raw" ] && exit 0
pick="${raw#\[session\] }"

if tmux has-session -t "$pick" 2>/dev/null; then
    target="$pick"
else
    name=$(basename "$pick" | tr '.' '_')
    tmux new-session -ds "$name" -c "$pick"
    target="$name"
fi

if [ -n "${TMUX:-}" ]; then
    tmux switch-client -t "$target"
else
    tmux attach -t "$target"
fi
