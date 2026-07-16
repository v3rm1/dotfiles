# Prompt
eval "$(starship init zsh)"
# ------------------------------------------------------------------------------
# Environment
# ------------------------------------------------------------------------------

# Export path to root of dotfiles repo
export CONFIG=${CONFIG:="$HOME/.config"}

# Locale
export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8
export LANGUAGE=en_US.UTF-8
# Stop zoxide from crying
export _ZO_DOCTOR=0

# Do not override files using `>`, but it's still possible using `>!`
set -o noclobber

# Extend $PATH without duplicates
_extend_path() {
  [[ -d "$1" ]] || return

  if ! $( echo "$PATH" | tr ":" "\n" | grep -qx "$1" ) ; then
    export PATH="$1:$PATH"
  fi
}

# Add custom bin to $PATH
_extend_path "$HOME/.local/bin"
_extend_path "$CONFIG"

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

if command -v brew &>/dev/null; then
  source "$(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
  source "$(brew --prefix)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
fi

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

# ---- TheFuck -----
command -v thefuck &>/dev/null && eval "$(thefuck --alias fuck fk)"

# ---- Zoxide (better cd) ----
command -v zoxide &>/dev/null && eval "$(zoxide init zsh)"

# ---- sesh (tmux session picker) ----
sesh-connect() {
  local raw session
  raw="$(sesh list -i -t -c -z | fzf --ansi --reverse --height 40%)" || return
  [[ -n "$raw" ]] || return
  session="${raw##*·}"
  BUFFER="sesh connect \"$session\""
  zle accept-line
}
if command -v sesh &>/dev/null; then
  zle -N sesh-connect
  bindkey '^G' sesh-connect
fi

source ~/.aliases
source ~/.zfuncs

[[ -f ~/.hf_token ]] && export HF_TOKEN="$(<~/.hf_token)"

fpath+=~/.zfunc; autoload -Uz compinit; compinit

zstyle ':completion:*' menu select

alias claude-plugin-updates='~/.claude/scripts/check-plugin-updates.sh'

# ------------------------------------------------------------------------------
# macOS-only (Homebrew, Android SDK, Antigravity IDE, mlflow tunnel)
# ------------------------------------------------------------------------------
if [[ "$(uname)" == "Darwin" ]]; then
  _extend_path "/opt/homebrew/sbin"
  _extend_path "$HOME/.rvm/bin"
  _extend_path "/Users/varunv/Library/Python/3.9/bin"
  _extend_path "/usr/local/texlive/2023basic/bin/universal-darwin"
  _extend_path "$HOME/.pixi/bin"

  # Lynx config
  export LYNX_CFG=~/.config/lynx/lynx.cfg
  # Declare android home
  export ANDROID_HOME="$HOME/Library/Android/sdk"
  _extend_path "$ANDROID_HOME/platform-tools:$PATH"

  export PATH="/opt/homebrew/opt/openjdk@17/bin:$PATH"

  # Added by Antigravity
  export PATH="/Users/varunv/.antigravity/antigravity/bin:$PATH"

  autossh -M 0 -f -N mlflow-tunnel
  alias burp="brew update && brew upgrade && brew doctor && brew cleanup"

  # Added by Antigravity CLI installer
  export PATH="/Users/varunv/.local/bin:$PATH"
fi
