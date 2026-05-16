# Project Notes

## Current State

Latest implemented release in this checkout: `v1.0.13`.

The app is a clean Swift/macOS implementation, not a fork of another project. It provides a Finder Sync extension with a `Create File` submenu.

Supported file types:

- `txt`
- `pdf`
- `docx`
- `xlsx`
- `pptx`

Developer file types, always available under `Create File > Developer Types`:

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
rm -rf "$HOME/Library/Application Support/MacCreateFileApp"
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

## Developer File Types Menu

From `v1.0.11`, there is no developer file type toggle and no shared settings path for this feature.

Finder always shows:

- Top-level `Create File` submenu with `txt`, `pdf`, `docx`, `xlsx`, `pptx`.
- Nested `Developer Types` submenu with `md`, `rtf`, `csv`, `json`, `html`, `css`, `js`, `py`, `swift`, `sh`.

This replaced the `v1.0.7` through `v1.0.10` toggle experiments, which either required Finder restarts, hit sandbox preference visibility issues, or triggered App Group privacy warnings.

## Icons

Implemented in `v1.0.12`:

- App icon is generated during build by `scripts/generate_app_icon.swift`.
- The generated app icon is written to `Contents/Resources/MacCreateFileAppIcon.icns`.
- `Info-App.plist` uses `CFBundleIconFile = MacCreateFileAppIcon`.
- Finder's top-level `Create File` extension menu item uses SF Symbol `doc.badge.plus`.

Updated in `v1.0.13`:

- Finder menu icons are template images so macOS can tint them for light/dark mode.
- `Copy Path` uses `doc.on.doc`.
- `Open Terminal Here` uses `terminal`.
- `Open Terminal Here` launches Terminal through `/usr/bin/open -a Terminal <folder>` instead of AppleScript.

## Build Commands

```sh
scripts/verify_project.sh
VERSION=1.0.13 scripts/package_release.sh
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
