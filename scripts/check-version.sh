#!/usr/bin/env bash
# Verify that all version references match the version in typst.toml.
#
# Usage: scripts/check-version.sh [EXPECTED_VERSION]
#
# If EXPECTED_VERSION is given (e.g. from a git tag like v1.2.3 or 1.2.3), it must match typst.toml as well.

source "$(dirname "${BASH_SOURCE[0]}")/common.sh"

status=0
import="@preview/$PACKAGE_NAME:$PACKAGE_VERSION"

if [[ $# -ge 1 ]]; then
  expected="${1#v}"
  if [[ "$expected" != "$PACKAGE_VERSION" ]]; then
    echo "::error::Version mismatch: expected $expected, but typst.toml has $PACKAGE_VERSION"
    status=1
  fi
fi

if ! grep -qF "#import \"$import\"" "$REPO_ROOT/template/main.typ"; then
  echo "::error file=template/main.typ::template/main.typ must import \"$import\""
  status=1
fi

# every versioned package reference in the README must point to the current version
while IFS= read -r ref; do
  if [[ "$ref" != "$import" ]]; then
    echo "::error file=README.md::README.md references $ref instead of $import"
    status=1
  fi
done < <(grep -oE "@preview/$PACKAGE_NAME:[0-9]+\.[0-9]+\.[0-9]+" "$REPO_ROOT/README.md" || true)

# links to files in this repository must point to the release tag
while IFS= read -r ref; do
  if [[ "$ref" != "/blob/v$PACKAGE_VERSION/" ]]; then
    echo "::error file=README.md::README.md links to $ref instead of /blob/v$PACKAGE_VERSION/"
    status=1
  fi
done < <(grep -oE "/blob/[^/]+/" "$REPO_ROOT/README.md" || true)

if [[ $status -eq 0 ]]; then
  echo "All version references match $PACKAGE_VERSION"
fi
exit $status
