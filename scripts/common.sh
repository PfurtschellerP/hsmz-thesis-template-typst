# shellcheck shell=bash disable=SC2034
# Shared helpers for the scripts in this directory. Source it, don't execute it.

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# Read a top-level key from the [package] section of typst.toml
manifest_value() {
  sed -n '/^\[package\]/,/^\[/p' "$REPO_ROOT/typst.toml" | sed -n "s/^$1 *= *\"\(.*\)\"/\1/p" | head -n 1
}

PACKAGE_NAME="$(manifest_value name)"
PACKAGE_VERSION="$(manifest_value version)"

# Every file tracked by git must match exactly one of the two patterns below; scripts/package.sh fails otherwise, so
# that a new file is never published (or left out) by accident.
# (see https://github.com/typst/packages/blob/main/docs/tips.md#what-to-commit-what-to-exclude)
#
# Files that are published to typst/packages: the manifest, docs, license, thumbnail, the library and the template
PACKAGE_PATTERN='^(typst\.toml|README\.md|LICENSE|thumbnail\.png|logo_hsmz\.svg|[^/]+\.typ|template/.+)$'
# Files that belong to the development repository only
DEV_ONLY_PATTERN='^(\.github/|\.vscode/|scripts/|\.gitignore$|RELEASING\.md$)'

# Create a temporary package directory in which @preview/<name>:<version> points to this checkout, so that the
# template can be compiled before the version is published. Prints the path to pass to `typst --package-path`.
local_package_path() {
  local dir
  dir="$(mktemp -d)"
  mkdir -p "$dir/preview/$PACKAGE_NAME"
  ln -s "$REPO_ROOT" "$dir/preview/$PACKAGE_NAME/$PACKAGE_VERSION"
  echo "$dir"
}
