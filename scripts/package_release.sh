#!/bin/sh
set -eu

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
VERSION="${VERSION:-1.0.0}"
ARCH="$(uname -m)"
APP_NAME="Mac Create File"
APP_BUNDLE="$ROOT_DIR/dist/$APP_NAME.app"
RELEASE_BASENAME="MacCreateFile-$VERSION-mac-$ARCH"
ZIP_PATH="$ROOT_DIR/dist/$RELEASE_BASENAME.zip"

"$ROOT_DIR/scripts/build_app.sh"

rm -f "$ZIP_PATH"

(
  cd "$ROOT_DIR/dist"
  ditto -c -k --keepParent "$APP_NAME.app" "$ZIP_PATH"
)

echo "Release files:"
echo "$ZIP_PATH"
