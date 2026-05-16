#!/bin/bash
set -u

EXTENSION_ID="com.sdenkrua.MacCreateFileApp.FinderExtension"
APP_PATH="/Applications/Mac Create File.app"

echo "Disabling Mac Create File Finder extension..."
/usr/bin/pluginkit -e ignore -i "$EXTENSION_ID" 2>/dev/null || true

echo "Restarting Finder..."
/usr/bin/killall Finder 2>/dev/null || true

echo "Removing extension support files..."
/bin/rm -rf "$HOME/Library/Application Scripts/$EXTENSION_ID"
/bin/rm -f "$HOME/Library/Logs/MacCreateFileApp.log"

CONTAINER_PATH="$HOME/Library/Containers/$EXTENSION_ID"
if [ -d "$CONTAINER_PATH" ]; then
  if /bin/rm -rf "$CONTAINER_PATH" 2>/dev/null; then
    echo "Removed extension container."
  else
    echo "macOS kept the extension container protected. This is safe to ignore after the extension is disabled."
  fi
fi

echo "Restarting preferences daemon..."
/usr/bin/killall cfprefsd 2>/dev/null || true

if [ -d "$APP_PATH" ]; then
  echo "The app is still installed at:"
  echo "$APP_PATH"
  echo "You can now move it to Trash safely."
fi

echo "Done. If Finder still shows the menu, log out and back in."
