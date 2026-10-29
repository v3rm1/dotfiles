# Dev toolchain for macOS: ./bootstrap.sh mac --tools (runs brew bundle)

# Rust: rustup honours per-project rust-toolchain.toml; replaces brew's rust
brew "rustup"

# C/C++
brew "llvm"          # clang, clang-tidy, lldb
brew "cmake"
brew "ninja"
brew "bear"          # compile_commands.json for make-based builds
brew "ccache"
brew "sccache"

# Systems / emulation
brew "qemu"
brew "aarch64-elf-gdb"

# Shell (everything .zshrc, .aliases and tmux.conf call out to)
brew "stow"
brew "tmux"
brew "neovim"
brew "starship"
brew "atuin"
brew "direnv"
brew "fzf"
brew "fd"
brew "ripgrep"
brew "bat"
brew "eza"
brew "dust"
brew "btop"
brew "lazygit"
brew "pay-respects"

# Remote: roaming sessions to uni-server (`us` in .zfuncs)
brew "mosh"

# Repo hygiene: pre-commit hooks for this repo
brew "pre-commit"
brew "gitleaks"
brew "shellcheck"

# Window management
cask "omniwm"
cask "kitty"

# General
brew "just"
brew "hyperfine"
brew "git-delta"
brew "difftastic"
brew "jq"
