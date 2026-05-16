#!/bin/sh
set -eu

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
APP_NAME="Mac Create File"

"$ROOT_DIR/scripts/build_app.sh"
rm -rf "/Applications/$APP_NAME.app"
ditto "$ROOT_DIR/dist/$APP_NAME.app" "/Applications/$APP_NAME.app"
open "/Applications/$APP_NAME.app"

echo "Installed /Applications/$APP_NAME.app"
