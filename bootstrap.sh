#!/usr/bin/env bash
set -euo pipefail
shopt -s dotglob nullglob

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MACHINES_DIR="$REPO_ROOT/machines"

usage() {
  echo "Usage: $0 <machine> [--dry-run] [--tools]" >&2
  echo "  --tools  also install the machine's dev toolchain" >&2
  echo "           (machines/<machine>.Brewfile or machines/<machine>.pacman)" >&2
  exit 1
}

[[ $# -ge 1 ]] || usage
MACHINE="$1"
shift
DRY_RUN=false
TOOLS=false
for arg in "$@"; do
  case "$arg" in
    --dry-run) DRY_RUN=true ;;
    --tools) TOOLS=true ;;
    *) usage ;;
  esac
done

PKGS_FILE="$MACHINES_DIR/$MACHINE.pkgs"
[[ -f "$PKGS_FILE" ]] || { echo "No such machine profile: $PKGS_FILE" >&2; exit 1; }

if ! command -v stow &>/dev/null; then
  echo "GNU Stow is not installed. Install it first." >&2
  exit 1
fi

# Reads non-empty, non-comment lines of $1 into the array named $2. Plain
# `while read` instead of mapfile so this runs on macOS's stock bash 3.2.
read_list() {
  local line
  eval "$2=()"
  while IFS= read -r line || [[ -n "$line" ]]; do
    line="${line%%#*}"
    line="${line#"${line%%[![:space:]]*}"}"
    line="${line%"${line##*[![:space:]]}"}"
    [[ -n "$line" ]] && eval "$2+=(\"\$line\")"
  done < "$1"
}

read_list "$PKGS_FILE" PACKAGES

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

if $TOOLS; then
  echo "== tools =="
  if [[ -f "$MACHINES_DIR/$MACHINE.Brewfile" ]]; then
    if $DRY_RUN; then
      brew bundle check --verbose --file="$MACHINES_DIR/$MACHINE.Brewfile" || true
    else
      brew bundle --file="$MACHINES_DIR/$MACHINE.Brewfile"
    fi
  elif [[ -f "$MACHINES_DIR/$MACHINE.pacman" ]]; then
    read_list "$MACHINES_DIR/$MACHINE.pacman" TOOL_PKGS
    if $DRY_RUN; then
      echo "  would install: ${TOOL_PKGS[*]}"
    else
      sudo pacman -S --needed "${TOOL_PKGS[@]}"
    fi
  else
    echo "  no tool list for $MACHINE" >&2
  fi
fi
