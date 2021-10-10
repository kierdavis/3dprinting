#!/bin/bash
set -o errexit -o nounset -o pipefail

here="$(dirname "$(readlink -f "$0")")"
ln -fsTv "$here/repetier" "$HOME/.mono/registry/CurrentUser/software/repetier"
