#!/usr/bin/env bash
# Fails if a tracked top-level stow package is not listed in any
# machines/*.pkgs profile, or if a profile lists a package that does not exist.
set -euo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")/.."

# Top-level entries that are repo plumbing, not stow packages.
NOT_PACKAGES="machines"

status=0
listed="$(sed 's/#.*//; s/[[:space:]]//g; /^$/d' machines/*.pkgs | sort -u)"

for pkg in $(git ls-files | grep / | cut -d/ -f1 | grep -v '^\.' | sort -u); do
  case " $NOT_PACKAGES " in *" $pkg "*) continue ;; esac
  if ! grep -qx "$pkg" <<<"$listed"; then
    echo "Package '$pkg' is not listed in any machines/*.pkgs" >&2
    status=1
  fi
done

for pkg in $listed; do
  if [[ ! -d "$pkg" ]]; then
    echo "machines/*.pkgs lists '$pkg' but no such directory exists" >&2
    status=1
  fi
done

exit $status
