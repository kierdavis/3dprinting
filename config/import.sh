#!/bin/sh
set -o errexit -o nounset -o pipefail

link() {
  if [[ -d "$2" ]]; then rm -rf "$2"; fi
  mkdir -p "$(dirname "$2")"
  ln -fsTv "$1" "$2"
}

here="$(dirname "$(readlink -f "$0")")"
link "$here/repetier" "$HOME/.mono/registry/CurrentUser/software/repetier"
link "$here/prusa-slicer" "$HOME/.config/PrusaSlicer"
