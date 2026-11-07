#!/usr/bin/env bash
# Set a new package version in typst.toml, template/main.typ and README.md.
#
# Usage: scripts/bump-version.sh NEW_VERSION   (e.g. 0.5.0)

source "$(dirname "${BASH_SOURCE[0]}")/common.sh"

new="${1:-}"
if [[ ! "$new" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
  echo "Usage: $0 NEW_VERSION (major.minor.patch, e.g. 0.5.0)" >&2
  exit 1
fi

old="$PACKAGE_VERSION"
if [[ "$new" == "$old" ]]; then
  echo "Version is already $new" >&2
  exit 1
fi

sed -i.bak "s/^version = \"$old\"/version = \"$new\"/" "$REPO_ROOT/typst.toml"
sed -i.bak "s|@preview/$PACKAGE_NAME:$old|@preview/$PACKAGE_NAME:$new|g" "$REPO_ROOT/template/main.typ" "$REPO_ROOT/README.md"
# links to files in this repository point to the release tag (required by typst/package-check)
sed -i.bak "s|/blob/v$old/|/blob/v$new/|g" "$REPO_ROOT/README.md"
rm -f "$REPO_ROOT/typst.toml.bak" "$REPO_ROOT/template/main.typ.bak" "$REPO_ROOT/README.md.bak"

echo "Bumped $PACKAGE_NAME from $old to $new"
"$REPO_ROOT/scripts/check-version.sh" "$new"

# move the local package link (scripts/link-local-package.sh) to the new version, if this checkout is linked
link="$(local_data_package_dir)/$old"
if [[ -L "$link" && "$(readlink "$link")" == "$REPO_ROOT" ]]; then
  "$REPO_ROOT/scripts/link-local-package.sh"
fi
