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

# Window management
cask "omniwm"

# General
brew "just"
brew "hyperfine"
brew "git-delta"
brew "jq"
