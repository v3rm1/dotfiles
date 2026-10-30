# dotfiles
dotfiles for *nix

Managed with GNU Stow. Each top-level directory is a stow package laid out as
`<package>/.config/<app>/...` (or a dotfile directly under the package root,
e.g. `zsh/.zshrc`), so `stow -t ~ <package>` symlinks it into place.

Run `./bootstrap.sh <machine>` to stow the package set for a given machine
profile (see `machines/*.pkgs`), or `stow -t ~ <package>` to link one manually.
Add `--tools` to also install that machine's dev toolchain from
`machines/<machine>.Brewfile` (macOS) or `machines/<machine>.pacman` (Arch).
Add `--system` to install files that live outside `$HOME` and cannot be stowed,
kept in `machines/<machine>/` (e.g. the Arch login greeter; needs sudo).

Machine-specific or private settings stay out of the repo: `~/.gitconfig.local`
(credential helper, signing) and `~/.ssh/config.local` (private hosts) are
included by the tracked configs when present.

A pre-commit config runs gitleaks (secret scanning), shellcheck, and `machines/check-packages.sh`, which fails if a
package directory is missing from every `machines/*.pkgs` profile. Enable it
once per clone with `pre-commit install`.

The liquid glass look (translucent Tokyo Night with blur and a neon rim) is set
per app. On Arch, `niri/.config/niri/glass.kdl` holds the opacity and blur tiers
and explains how to add an app.
