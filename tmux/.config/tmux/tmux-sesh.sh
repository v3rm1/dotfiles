#!/usr/bin/env bash
# tmux session picker: live sessions + zoxide dirs, fzf-picked, attach or create.
set -euo pipefail

cur=$(tmux display-message -p '#S' 2>/dev/null || true)

{
    tmux list-sessions -F '#S' 2>/dev/null | grep -v "^${cur}\$" | sed 's/^/[session] /' || true
    zoxide query -l
} | fzf --no-sort --ansi --border-label ' sesh ' \
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
