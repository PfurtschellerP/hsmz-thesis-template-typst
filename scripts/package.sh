#!/usr/bin/env bash
# Assemble the package as it will be submitted to typst/packages.
#
# Usage: scripts/package.sh [OUTPUT_DIR]
#
# Creates OUTPUT_DIR/<name>/<version>/ (default OUTPUT_DIR: dist) containing all files tracked by git, except for
# development-only files (CI, scripts, release docs). Copy that directory to packages/preview/ in your fork of
# typst/packages.

source "$(dirname "${BASH_SOURCE[0]}")/common.sh"

out_root="${1:-$REPO_ROOT/dist}"
target="$out_root/$PACKAGE_NAME/$PACKAGE_VERSION"

rm -rf "$target"
mkdir -p "$target"

cd "$REPO_ROOT"
git ls-files -z | grep -zvE "$DEV_ONLY_PATTERN" | while IFS= read -r -d '' file; do
  mkdir -p "$target/$(dirname "$file")"
  cp "$file" "$target/$file"
done

echo "Package written to $target"
