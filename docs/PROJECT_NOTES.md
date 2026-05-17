# Project Notes

## Current State

Latest implemented release in this checkout: `v1.0.21`.

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

Updated in `v1.0.15`:

- Main app includes an `Uninstall Completely` / `Видалити повністю` button.
- The app-side uninstall flow disables the Finder extension, restarts Finder, removes logs/support files/legacy App Group files, removes the extension container where macOS allows it, and restarts `cfprefsd`.
- The app does not delete itself from `/Applications`; after cleanup, the user should move `Mac Create File.app` to Trash.
- `uninstall.command` remains in release packages as a fallback for cases where the app was already deleted or cannot be opened.

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

Updated in `v1.0.14`:

- Finder Sync did not tint SF Symbol menu icons reliably in dark mode.
- The extension now draws its own 16x16 outline menu icons.
- Icon stroke color is selected from `NSApp.effectiveAppearance`: light stroke in dark mode, dark stroke in light mode.

Updated in `v1.0.18`:

- Menu icon stroke weight was reduced from `1.7` to about `1.25`.
- `Create File` plus mark was moved inside the document outline.
- `Copy Path` and `Open Terminal Here` glyphs were tightened to better match native Finder menu icon weight.
- Ukrainian Finder menu label uses `Термінал`.

Updated in `v1.0.19`:

- Menu icon stroke weight was reduced again to about `1.15`.
- Document folded corners are larger and closer to Finder's native document icon shape.
- `Copy Path` now draws only the visible portion of the back document, with the front document reading as the primary shape.

Updated in `v1.0.20`:

- `Create File` and `Copy Path` document glyphs were redrawn again after user visual review.
- The front document now has a larger folded corner and lighter internal fold line.
- `Copy Path` uses a partial back-document hint so it reads as one document in front of another instead of two full overlapping outlines.

## Cloud Folder Coverage

Updated in `v1.0.20`:

- Finder Sync no longer relies only on `directoryURLs = ["/"]`.
- The extension now explicitly monitors `/`, the user's Desktop and Documents folders, `~/Library/CloudStorage`, each installed CloudStorage provider root, `~/Library/Mobile Documents`, and iCloud Drive at `~/Library/Mobile Documents/com~apple~CloudDocs` when those folders exist.
- This is a pragmatic first fix for iCloud Drive, Desktop/Documents-in-iCloud, OneDrive, and similar File Provider folders where Finder Sync can behave differently from normal local folders.
- The extension writes the final monitored roots to `~/Library/Logs/MacCreateFileApp.log` on startup.
- If a cloud provider still blocks file creation after the menu appears, the next escalation is a user-granted folder access flow with security-scoped bookmarks stored for the extension without reintroducing App Group prompts.

Fixed in `v1.0.21`:

- The `v1.0.20` cloud-root implementation used `NSHomeDirectoryForUser(NSUserName())`, which resolves to the Finder extension sandbox home while the extension is sandboxed.
- The extension now resolves the real current-user home with `getpwuid(getuid())`, so monitored roots are built from the actual `/Users/<name>` home on any Mac.
- Extension logging intentionally stays inside the extension container at `~/Library/Containers/com.sdenkrua.MacCreateFileApp.FinderExtension/Data/Library/Logs/MacCreateFileApp.log`, because that path is writable from the sandbox.
- If direct file creation fails in Desktop, Documents, iCloud Drive, OneDrive, or another protected/cloud folder, the extension now creates a temporary source file inside its sandbox and asks Finder to duplicate it into the target folder through AppleScript.
- This keeps the normal fast direct write for folders where it works and adds a Finder-mediated fallback for protected/cloud locations.

## Bundled File Templates

Implemented in `v1.0.16`:

- `pdf`, `docx`, `xlsx`, and `pptx` are copied from real blank files in `ExtensionResources/Templates`.
- Text/code-oriented file types still use generated text content.
- `MinimalFiles.swift` was removed because minimal hand-built OOXML/PDF files were not compatible enough with strict apps such as Keynote.
- Current bundled templates:
  - `Blank PDF.pdf`
  - `Blank Word.docx`
  - `Blank Excel.xlsx`
  - `Blank Presentation.pptx`
  - `Blank Pages.pages`
  - `Blank Numbers.numbers`
  - `Blank Keynote.key`

Implemented in `v1.0.17`:

- Added `Create File > Apple iWork`.
- Added Pages (`.pages`), Numbers (`.numbers`), and Keynote (`.key`) file creation from bundled templates.

## Build Commands

```sh
scripts/verify_project.sh
VERSION=1.0.21 scripts/package_release.sh
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
