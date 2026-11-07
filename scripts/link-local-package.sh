#!/usr/bin/env bash
# Link this checkout as the local package @preview/<name>:<version> (version from typst.toml), so that Typst and the
# editor (Tinymist) use the checkout instead of downloading the package. This is needed while the version is not
# published yet, e.g. after scripts/bump-version.sh.
#
# Usage: scripts/link-local-package.sh            create or update the link
#        scripts/link-local-package.sh --remove   remove it (use the published versions again)
#
# Links of other versions that point to this checkout are removed, so that only the current version is redirected and
# other projects that use a published version are not affected.

source "$(dirname "${BASH_SOURCE[0]}")/common.sh"

dir="$(local_data_package_dir)"

remove_links() {
  local link
  for link in "$dir"/*; do
    if [[ -L "$link" && "$(readlink "$link")" == "$REPO_ROOT" ]]; then
      rm "$link"
      echo "Removed link $link"
    fi
  done
}

case "${1:-}" in
  --remove)
    remove_links
    exit 0
    ;;
  "") ;;
  *)
    echo "Usage: $0 [--remove]" >&2
    exit 1
    ;;
esac

target="$dir/$PACKAGE_VERSION"
if [[ -e "$target" && ! -L "$target" ]]; then
  echo "error: $target exists and is not a link. Remove it first." >&2
  exit 1
fi

remove_links
mkdir -p "$dir"
ln -sfn "$REPO_ROOT" "$target"
echo "Linked @preview/$PACKAGE_NAME:$PACKAGE_VERSION to $REPO_ROOT"
echo "Run '$0 --remove' to use the published versions again."
