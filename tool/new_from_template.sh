#!/usr/bin/env bash
# Copy code_store (or current repo) into a sibling folder and rename the Dart package.
# Usage: ./tool/new_from_template.sh <new_project_name>
# Example: ./tool/new_from_template.sh my_cool_app
set -euo pipefail

NEW_NAME="${1:-}"
if [[ -z "$NEW_NAME" ]]; then
  echo "Usage: $0 <new_project_name>" >&2
  exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
DEST="$(cd "$ROOT/.." && pwd)/${NEW_NAME}"

if [[ -e "$DEST" ]]; then
  echo "Destination already exists: $DEST" >&2
  exit 1
fi

echo "Copying $ROOT -> $DEST"
cp -R "$ROOT" "$DEST"

# Remove VCS metadata from the copy so the new folder is a clean tree (optional).
rm -rf "$DEST/.git" 2>/dev/null || true

OLD_PKG="code_store"

echo "Renaming package $OLD_PKG -> $NEW_NAME in $DEST"
# pubspec name
if [[ "$(uname)" == "Darwin" ]]; then
  sed -i '' "s/^name: ${OLD_PKG}\$/name: ${NEW_NAME}/" "$DEST/pubspec.yaml"
else
  sed -i "s/^name: ${OLD_PKG}\$/name: ${NEW_NAME}/" "$DEST/pubspec.yaml"
fi

# Dart imports and parts
while IFS= read -r -d '' f; do
  sed -i.bak "s/package:${OLD_PKG}\//package:${NEW_NAME}\//g" "$f" && rm -f "${f}.bak"
done < <(find "$DEST/lib" -name '*.dart' -print0)
if [[ -d "$DEST/test" ]]; then
  while IFS= read -r -d '' f; do
    sed -i.bak "s/package:${OLD_PKG}\//package:${NEW_NAME}\//g" "$f" && rm -f "${f}.bak"
  done < <(find "$DEST/test" -name '*.dart' -print0)
fi

echo "Running flutter pub get in $DEST"
(cd "$DEST" && flutter pub get)

echo "Done. Next: cd \"$DEST\" && flutterfire configure  # then open in your IDE"
