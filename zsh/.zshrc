# ------------------------------------------------------------------------------
# Environment
# ------------------------------------------------------------------------------

# Export path to root of dotfiles repo
export CONFIG=${CONFIG:="$HOME/.config"}

# Locale
export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8
export LANGUAGE=en_US.UTF-8

# Do not override files using `>`, but it's still possible using `>!`
set -o noclobber

# Extend $PATH without duplicates: `typeset -U` keeps the path array unique,
# and missing directories are skipped so per-machine entries are harmless.
typeset -U path PATH
_extend_path() {
  [[ -d "$1" ]] && path=("$1" $path)
}

# Add custom bin to $PATH
_extend_path "$HOME/.local/bin"
_extend_path "$HOME/.cargo/bin"
_extend_path "$CONFIG"

# Prompt -- must come after PATH is extended, since starship may live in
# $HOME/.local/bin on machines where it isn't packaged system-wide
eval "$(starship init zsh)"

# less options
less_opts=(
  # Quit if entire file fits on first screen.
  -FX
  # Ignore case in searches that do not contain uppercase.
  --ignore-case
  # Allow ANSI colour escapes, but no other escapes.
  --RAW-CONTROL-CHARS
  # Quiet the terminal bell. (when trying to scroll past the end of the buffer)
  --quiet
  # Do not complain when we are on a dumb terminal.
  --dumb
)
export LESS="${less_opts[*]}"

# Default editor to nvim
export EDITOR=nvim

# history setup
HISTFILE=$HOME/.zhistory
SAVEHIST=1000
HISTSIZE=999
setopt share_history
setopt hist_expire_dups_first
setopt hist_ignore_dups
setopt hist_verify
setopt autocd
# completion using arrow keys (based on history)
bindkey '^[[A' history-search-backward
bindkey '^[[B' history-search-forward

# direnv settings
command -v direnv &>/dev/null && eval "$(direnv hook zsh)"

# Completion: compinit must run before fzf-tab (loaded by antidote below).
fpath+=~/.zfunc; autoload -Uz compinit
# Dump file lives on local disk, not $HOME -- avoids compinit hanging on
# NFS/Ceph-style network homes where lock/write contention on a shared
# .zcompdump can stall shell startup indefinitely.
compinit -d "${TMPDIR:-/tmp}/zcompdump-$HOST-$ZSH_VERSION"

# ---- FZF -----
if command -v fzf &>/dev/null; then
  source <(fzf --zsh)

  export FZF_DEFAULT_OPTS="$FZF_DEFAULT_OPTS \
    --highlight-line \
    --info=inline-right \
    --ansi \
    --layout=reverse \
    --border=none \
    --color=bg+:#2e3c64 \
    --color=bg:#1f2335 \
    --color=border:#29a4bd \
    --color=fg:#c0caf5 \
    --color=gutter:#1f2335 \
    --color=header:#ff9e64 \
    --color=hl+:#2ac3de \
    --color=hl:#2ac3de \
    --color=info:#545c7e \
    --color=marker:#ff007c \
    --color=pointer:#ff007c \
    --color=prompt:#2ac3de \
    --color=query:#c0caf5:regular \
    --color=scrollbar:#29a4bd \
    --color=separator:#ff9e64 \
    --color=spinner:#ff007c \
  "

  export FZF_DEFAULT_COMMAND="fd --hidden --strip-cwd-prefix --exclude .git"
  export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
  export FZF_ALT_C_COMMAND="fd --type=d --hidden --strip-cwd-prefix --exclude .git"

  # Use fd (https://github.com/sharkdp/fd) for listing path candidates.
  _fzf_compgen_path() {
    fd --hidden --exclude .git . "$1"
  }

  # Use fd to generate the list for directory completion
  _fzf_compgen_dir() {
    fd --type=d --hidden --exclude .git . "$1"
  }

  show_file_or_dir_preview="if [ -d {} ]; then eza --tree --color=always {} | head -200; else bat -n --color=always --line-range :500 {}; fi"

  export FZF_CTRL_T_OPTS="--preview '$show_file_or_dir_preview'"
  export FZF_ALT_C_OPTS="--preview 'eza --tree --color=always {} | head -200'"

  # Advanced customization of fzf options via _fzf_comprun function
  _fzf_comprun() {
    local command=$1
    shift

    case "$command" in
      cd)           fzf --preview 'eza --tree --color=always {} | head -200' "$@" ;;
      export|unset) fzf --preview "eval 'echo \${}'"         "$@" ;;
      ssh)          fzf --preview 'dig {}'                   "$@" ;;
      *)            fzf --preview "$show_file_or_dir_preview" "$@" ;;
    esac
  }
fi

# ---- atuin: SQLite shell history on Ctrl-R (after fzf, so it owns Ctrl-R) -----
if command -v atuin &>/dev/null; then
  eval "$(atuin init zsh --disable-up-arrow)"
fi

# ---- Plugins via antidote (cloned on first run; same set on every machine) -----
# fzf-tab, zsh-abbr, forgit, autosuggestions, syntax-highlighting: see
# ~/.zsh_plugins.txt. Forgit aliases that clash with the git abbreviations
# get an "f" prefix.
export ABBR_USER_ABBREVIATIONS_FILE="$HOME/.config/zsh-abbr/user-abbreviations"
export forgit_add=fga forgit_diff=fgd forgit_checkout_file=fgcf forgit_switch_branch=fgsw
export forgit_clean=fgclean forgit_blame=fgbl forgit_worktree=fgwt
[[ -d ${ZDOTDIR:-$HOME}/.antidote ]] ||
  git clone --depth=1 https://github.com/mattmc3/antidote.git ${ZDOTDIR:-$HOME}/.antidote
source ${ZDOTDIR:-$HOME}/.antidote/antidote.zsh
antidote load

# fzf-tab: completion menu in fzf, with previews
zstyle ':completion:*' menu no
zstyle ':completion:*:descriptions' format '[%d]'
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
zstyle ':fzf-tab:*' use-fzf-default-opts yes
zstyle ':fzf-tab:*' switch-group '<' '>'
zstyle ':fzf-tab:complete:(cd|z|eza|ls):*' fzf-preview 'eza -1 --color=always $realpath'
zstyle ':fzf-tab:complete:(nvim|n|bat|cat):*' fzf-preview 'bat -n --color=always --line-range :200 $realpath 2>/dev/null || eza -1 --color=always $realpath'
zstyle ':fzf-tab:complete:git-(add|diff|restore):*' fzf-preview 'git diff $word | delta 2>/dev/null || git diff --color=always $word'
zstyle ':fzf-tab:complete:git-(checkout|switch):*' fzf-preview 'git log --oneline --graph --color=always $word | head -50'
# Keep fzf's `**<Tab>` trigger: fzf-completion handles `**`, else falls back to fzf-tab
if (( $+widgets[fzf-completion] )); then
  fzf_default_completion=fzf-tab-complete
  bindkey '^I' fzf-completion
fi

# ---- pay-respects (thefuck replacement) -----
if command -v pay-respects &>/dev/null; then
  eval "$(pay-respects zsh --alias fk)"
  alias fuck=fk
fi

# ---- tmux session picker ----
if command -v tmux &>/dev/null; then
  bindkey -s '^G' '~/.config/tmux/tmux-sesh.sh\n'
fi

source ~/.aliases
source ~/.zfuncs

[[ -f ~/.hf_token ]] && export HF_TOKEN="$(<~/.hf_token)"


alias claude-plugin-updates='~/.claude/scripts/check-plugin-updates.sh'

# ------------------------------------------------------------------------------
# macOS-only (Homebrew, Antigravity IDE, mlflow tunnel)
# ------------------------------------------------------------------------------
if [[ "$(uname)" == "Darwin" ]]; then
  _extend_path "/opt/homebrew/sbin"
  _extend_path "$HOME/.rvm/bin"
  _extend_path "$HOME/Library/Python/3.9/bin"
  _extend_path "/usr/local/texlive/2023basic/bin/universal-darwin"
  _extend_path "$HOME/.pixi/bin"

  # Lynx config
  export LYNX_CFG=~/.config/lynx/lynx.cfg

  _extend_path "/opt/homebrew/opt/openjdk@17/bin"

  # Antigravity IDE
  _extend_path "$HOME/.antigravity/antigravity/bin"

  # One tunnel for all shells, not one per new shell/tmux pane
  pgrep -qf 'autossh.*mlflow-tunnel' || autossh -M 0 -f -N mlflow-tunnel
  alias burp="brew update && brew upgrade && brew doctor && brew cleanup"
fi

# Per-machine overrides, untracked
[[ -f "$HOME/.zshrc.local" ]] && source "$HOME/.zshrc.local"
