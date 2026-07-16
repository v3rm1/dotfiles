# dotfiles
dotfiles for *nix

Managed with GNU Stow. Each top-level directory is a stow package laid out as
`<package>/.config/<app>/...` (or a dotfile directly under the package root,
e.g. `zsh/.zshrc`), so `stow -t ~ <package>` symlinks it into place.

Run `./bootstrap.sh <machine>` to stow the package set for a given machine
profile (see `machines/*.pkgs`), or `stow -t ~ <package>` to link one manually.

The quickshell config is still a work in progress, modifying caelestia for my usage.
