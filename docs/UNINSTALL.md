# Uninstall and Stale Finder Menu Notes

## Problem

After deleting `Mac Create File.app`, the Finder right-click menu item can remain visible.

This happens because macOS manages Finder Sync extensions through PlugInKit. The extension can stay registered or cached even when the app bundle has been removed.

## Manual Fix

Run:

```sh
pluginkit -e ignore -i com.sdenkrua.MacCreateFileApp.FinderExtension
killall Finder
```

Check status:

```sh
pluginkit -m -A | grep -i "MacCreate"
```

If the result starts with `-`, the extension is disabled.

## Optional Cleanup

```sh
rm -rf "$HOME/Library/Application Scripts/com.sdenkrua.MacCreateFileApp.FinderExtension"
rm -rf "$HOME/Library/Containers/com.sdenkrua.MacCreateFileApp.FinderExtension" 2>/dev/null || true
rm -f "$HOME/Library/Logs/MacCreateFileApp.log"
rm -rf "$HOME/Library/Application Support/MacCreateFileApp"
killall cfprefsd
```

## Built-In Fix

Since `v1.0.5`, the app provides a supported uninstall flow:

- A `Disable Finder Extension` button in the app.
- A user-facing `uninstall.command` script in the release zip.
- README instructions explaining that the Finder extension must be disabled before deleting the app.
