#!/bin/sh
set -eu

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
VERSION="${VERSION:-1.0.0}"
ARCH="$(uname -m)"
APP_NAME="Mac Create File"
APP_BUNDLE="$ROOT_DIR/dist/$APP_NAME.app"
RELEASE_BASENAME="MacCreateFile-$VERSION-mac-$ARCH"
ZIP_PATH="$ROOT_DIR/dist/$RELEASE_BASENAME.zip"
PACKAGE_DIR="$ROOT_DIR/build/release-package"

"$ROOT_DIR/scripts/build_app.sh"

rm -f "$ZIP_PATH"
rm -rf "$PACKAGE_DIR"
mkdir -p "$PACKAGE_DIR"
ditto "$APP_BUNDLE" "$PACKAGE_DIR/$APP_NAME.app"
cp "$ROOT_DIR/scripts/uninstall.command" "$PACKAGE_DIR/uninstall.command"
chmod +x "$PACKAGE_DIR/uninstall.command"

(
  cd "$PACKAGE_DIR"
  /usr/bin/zip -qry "$ZIP_PATH" "$APP_NAME.app" uninstall.command
)

echo "Release files:"
echo "$ZIP_PATH"
