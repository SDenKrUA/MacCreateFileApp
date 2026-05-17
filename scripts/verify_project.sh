#!/bin/sh
set -eu

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"

plutil -lint "$ROOT_DIR/Info-App.plist"
plutil -lint "$ROOT_DIR/Info-Extension.plist"
plutil -lint "$ROOT_DIR/Entitlements-Extension.plist"
plutil -lint "$ROOT_DIR/Resources/en.lproj/Localizable.strings"
plutil -lint "$ROOT_DIR/Resources/uk.lproj/Localizable.strings"
plutil -lint "$ROOT_DIR/ExtensionResources/en.lproj/Localizable.strings"
plutil -lint "$ROOT_DIR/ExtensionResources/uk.lproj/Localizable.strings"
test -x "$ROOT_DIR/scripts/uninstall.command"

swiftc -parse "$ROOT_DIR/Sources/MacCreateFileApp/MacCreateFileApp.swift"
swiftc -parse "$ROOT_DIR/Sources/MacCreateFileFinderExtension/FinderSync.swift"

echo "Project files passed plist and Swift parse checks."
