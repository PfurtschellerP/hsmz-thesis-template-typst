# Shared helpers for the scripts in this directory. Source it, don't execute it.

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# Read a top-level key from the [package] section of typst.toml
manifest_value() {
  sed -n '/^\[package\]/,/^\[/p' "$REPO_ROOT/typst.toml" | sed -n "s/^$1 *= *\"\(.*\)\"/\1/p" | head -n 1
}

PACKAGE_NAME="$(manifest_value name)"
PACKAGE_VERSION="$(manifest_value version)"

# Files that belong to the development repository only and must not be part of the published package
# (see https://github.com/typst/packages/blob/main/docs/tips.md#what-to-commit-what-to-exclude)
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
