#!/usr/bin/env bash
# Compile the template against this checkout (no need to publish or install the package first).
#
# Usage: scripts/compile-template.sh [OUTPUT] [EXTRA TYPST ARGS...]
#
# Examples:
#   scripts/compile-template.sh                      # -> template/main.pdf
#   scripts/compile-template.sh thesis.pdf
#   TYPST=typst-0.15.0 scripts/compile-template.sh   # use a specific compiler binary
#
# To regenerate the Typst Universe thumbnail (the title page, i.e. page 2):
#   scripts/compile-template.sh thumbnail.png --format png --pages 2 --ppi 250

source "$(dirname "${BASH_SOURCE[0]}")/common.sh"

typst="${TYPST:-typst}"
output="${1:-$REPO_ROOT/template/main.pdf}"
shift || true

package_path="$(local_package_path)"
trap 'rm -rf "$package_path"' EXIT

"$typst" compile --package-path "$package_path" --root "$REPO_ROOT" "$@" "$REPO_ROOT/template/main.typ" "$output"
echo "Compiled template to $output"
