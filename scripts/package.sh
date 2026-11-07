#!/usr/bin/env bash
# Assemble the package as it will be submitted to typst/packages.
#
# Usage: scripts/package.sh [OUTPUT_DIR]
#
# Creates OUTPUT_DIR/<name>/<version>/ (default OUTPUT_DIR: dist) containing only the files tracked by git that match
# PACKAGE_PATTERN in common.sh (manifest, README, license, thumbnail, library and template). CI files, editor settings,
# scripts and release docs are never copied. Fails if a tracked file matches neither PACKAGE_PATTERN nor
# DEV_ONLY_PATTERN. Copy the resulting directory to packages/preview/ in your fork of typst/packages.

source "$(dirname "${BASH_SOURCE[0]}")/common.sh"

out_root="${1:-$REPO_ROOT/dist}"
target="$out_root/$PACKAGE_NAME/$PACKAGE_VERSION"

rm -rf "$target"
mkdir -p "$target"

cd "$REPO_ROOT"
mapfile -d '' files < <(git ls-files -z)

unclassified=()
package_files=()
for file in "${files[@]}"; do
  if [[ $file =~ $PACKAGE_PATTERN ]] && [[ $file =~ $DEV_ONLY_PATTERN ]]; then
    unclassified+=("$file (matches both patterns)")
  elif [[ $file =~ $PACKAGE_PATTERN ]]; then
    package_files+=("$file")
  elif ! [[ $file =~ $DEV_ONLY_PATTERN ]]; then
    unclassified+=("$file")
  fi
done

if ((${#unclassified[@]})); then
  echo "error: add these files to PACKAGE_PATTERN or DEV_ONLY_PATTERN in scripts/common.sh:" >&2
  printf '  %s\n' "${unclassified[@]}" >&2
  exit 1
fi

for file in "${package_files[@]}"; do
  mkdir -p "$target/$(dirname "$file")"
  cp "$file" "$target/$file"
done

echo "Package written to $target"
