#!/usr/bin/env bash
set -euo pipefail
shopt -s dotglob nullglob

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MACHINES_DIR="$REPO_ROOT/machines"

usage() {
  echo "Usage: $0 <machine> [--dry-run]" >&2
  exit 1
}

[[ $# -ge 1 ]] || usage
MACHINE="$1"
DRY_RUN=false
[[ "${2:-}" == "--dry-run" ]] && DRY_RUN=true

PKGS_FILE="$MACHINES_DIR/$MACHINE.pkgs"
[[ -f "$PKGS_FILE" ]] || { echo "No such machine profile: $PKGS_FILE" >&2; exit 1; }

if ! command -v stow &>/dev/null; then
  echo "GNU Stow is not installed. Install it first." >&2
  exit 1
fi

mapfile -t PACKAGES < <(grep -v '^[[:space:]]*#' "$PKGS_FILE" | grep -v '^[[:space:]]*$')

# Walks the package tree looking for the old manual symlink to remove.
# Stops recursing as soon as it finds a symlink at $HOME/<rel> -- that's the
# old link (whether it was originally made per-file or per-directory) -- and
# removes it (or reports it, in dry-run mode) without descending further.
# Real (non-symlink) files/dirs at a target path are left alone here; Stow's
# own conflict detection is the authority on those and safely refuses to
# clobber them.
clean_old_symlink() {
  local src="$1" rel="$2"
  local target="$HOME/$rel"

  if [[ -L "$target" ]]; then
    if $DRY_RUN; then
      echo "  would remove existing symlink: $target"
    else
      rm "$target"
    fi
    return
  fi

  if [[ -d "$src" ]]; then
    for child in "$src"/*; do
      [[ -e "$child" ]] || continue
      local name
      name="$(basename "$child")"
      clean_old_symlink "$child" "${rel:+$rel/}$name"
    done
  fi
}

for pkg in "${PACKAGES[@]}"; do
  pkg_dir="$REPO_ROOT/$pkg"
  [[ -d "$pkg_dir" ]] || { echo "Package directory missing: $pkg_dir" >&2; exit 1; }

  echo "== $pkg =="

  for entry in "$pkg_dir"/*; do
    [[ -e "$entry" ]] || continue
    clean_old_symlink "$entry" "$(basename "$entry")"
  done

  if $DRY_RUN; then
    # stow -n refuses over any pre-existing symlink it didn't create itself,
    # even ones already printed above as "would remove" -- that removal only
    # actually happens on a real run, so this failure is expected here and
    # isn't a reason to stop previewing the rest of the packages.
    stow -n -v -d "$REPO_ROOT" -t "$HOME" "$pkg" || true
  else
    stow -v -d "$REPO_ROOT" -t "$HOME" --restow "$pkg"
  fi
done
