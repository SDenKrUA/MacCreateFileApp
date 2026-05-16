# Project Notes

## Current State

Latest implemented release in this checkout: `v1.0.6`.

The app is a clean Swift/macOS implementation, not a fork of another project. It provides a Finder Sync extension with a `Create File` submenu.

Supported file types:

- `txt`
- `md`
- `rtf`
- `csv`
- `json`
- `html`
- `css`
- `js`
- `py`
- `swift`
- `sh`
- `pdf`
- `docx`
- `xlsx`
- `pptx`

## Key Debug History

### Finder extension did not appear

Cause:

- The extension was initially built as a shared library instead of a proper app-extension executable.
- PlugInKit ignored it.

Fix:

- Build extension with `-emit-executable`.
- Use `_NSExtensionMain`.
- Add Finder extension entitlements.
- Register with `pluginkit -a`.

### `PKDiscoverAll` error after enabling

Cause:

- The main app was sandboxed and called `pluginkit -m`.

Fix:

- Main app is no longer sandboxed.
- Enable flow no longer calls `pluginkit -m`.

### Menu appeared but file type clicks did nothing

Cause:

- Finder displayed submenu items, but the generic Swift action using `representedObject` was not reliably invoked.

Fix:

- Each menu item now uses an explicit `@objc` selector:
  - `createTextFile:`
  - `createWordDocument:`
  - `createExcelWorkbook:`
  - and so on.

### File creation target folder could be missing

Cause:

- Finder Sync can return empty `targetedURL()` and `selectedItemURLs()` depending on where the user right-clicks.

Fix:

- Fallback to Finder AppleScript `insertion location`.
- Log diagnostics to `~/Library/Logs/MacCreateFileApp.log`.
- Show errors instead of silently returning.

### Finder menu remains after app deletion

Cause:

- PlugInKit keeps extension registration separately from the app.
- Finder caches extension menus.

Manual fix:

```sh
pluginkit -e ignore -i com.sdenkrua.MacCreateFileApp.FinderExtension
killall Finder
```

Optional cleanup:

```sh
rm -rf "$HOME/Library/Application Scripts/com.sdenkrua.MacCreateFileApp.FinderExtension"
rm -rf "$HOME/Library/Containers/com.sdenkrua.MacCreateFileApp.FinderExtension" 2>/dev/null || true
rm -f "$HOME/Library/Logs/MacCreateFileApp.log"
killall cfprefsd
```

## Uninstall Flow

Implemented in `v1.0.5`:

- `Disable Finder Extension` button in the main app.
- `scripts/uninstall.command`.
- Uninstall instructions in both READMEs.
- `uninstall.command` included in the release `.zip`.

Future polish ideas:

1. Add a visible installed/enabled status indicator.
2. Add a one-click "Open Logs" button.
3. Add a signed/notarized release pipeline.

## Build Commands

```sh
scripts/verify_project.sh
VERSION=1.0.6 scripts/package_release.sh
```

## Release Shape

The project should release:

```text
MacCreateFile-<version>-mac-arm64.zip
```

The zip should contain:

```text
Mac Create File.app
uninstall.command
```

Do not publish `.dmg` unless explicitly requested.
