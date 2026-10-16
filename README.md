# dotfiles
dotfiles for *nix

Managed with GNU Stow. Each top-level directory is a stow package laid out as
`<package>/.config/<app>/...` (or a dotfile directly under the package root,
e.g. `zsh/.zshrc`), so `stow -t ~ <package>` symlinks it into place.

Run `./bootstrap.sh <machine>` to stow the package set for a given machine
profile (see `machines/*.pkgs`), or `stow -t ~ <package>` to link one manually.
Add `--tools` to also install that machine's dev toolchain from
`machines/<machine>.Brewfile` (macOS) or `machines/<machine>.pacman` (Arch).

Machine-specific or private settings stay out of the repo: `~/.gitconfig.local`
(credential helper, signing) and `~/.ssh/config.local` (private hosts) are
included by the tracked configs when present.

The quickshell config is still a work in progress, modifying caelestia for my usage.
