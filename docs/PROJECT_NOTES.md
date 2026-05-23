# Project Notes

## Current State

Latest implemented release in this checkout: `v1.0.23`.

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
- `uninstall.command` included in release packages.

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

Fixed in `v1.0.22`:

- Added the real user home directory itself to Finder Sync monitored roots. This makes Finder call the extension for cloud-backed subfolders such as `~/Documents/Тест`, where monitoring only `~/Documents` did not consistently trigger observation.
- Added diagnostic logs for `beginObservingDirectory`, `endObservingDirectory`, and `menu(for:)` calls. These stay useful for future Finder Sync issues and are written to the extension container log.
- File creation now prefers `FIFinderSyncController.default().targetedURL()` over `selectedItemURLs()`. This avoids stale Finder sidebar/search selected URLs such as `myDocuments.cannedSearch` overriding the actual folder that was right-clicked.

Added in `v1.0.23`:

- The main app now has an `Allowed Folders` / `Дозволені папки` section.
- Users can add custom folders through `NSOpenPanel`, or quickly add Desktop, Documents, iCloud Drive, and CloudStorage.
- Allowed folders are stored in the Finder extension container at `~/Library/Containers/com.sdenkrua.MacCreateFileApp.FinderExtension/Data/Library/Application Support/MacCreateFileApp/AllowedFolders.plist`.
- This avoids App Group sharing, which previously triggered macOS privacy warnings in this app.
- The Finder extension reads allowed folder bookmarks, starts security-scoped access when available, and adds those folders to `directoryURLs` on top of the default roots.
- If a bookmark cannot be resolved, the extension logs the failure and falls back to the stored path as a monitored folder so diagnostics remain possible.

Investigated on 2026-05-18:

- `~/Documents` and `~/Desktop` can be File Provider-backed even though they look like normal home folders. On the test Mac they carry `com.apple.file-provider-domain-id = com.apple.CloudDocs.iCloudDriveFileProvider/...`.
- In `~/Documents/Тест`, Finder calls `beginObservingDirectory`, so the monitored roots are accepted, but Finder does not call `menu(for:)` for the background context menu. The same installed extension still receives `menu(for:)` and shows the menu in local folders such as `~/Downloads`.
- Adding Desktop and `~/Documents/Тест` to Allowed Folders did not make Finder call `menu(for:)` in that File Provider folder. The bookmarks currently resolve only as stored paths in local ad-hoc builds; `withSecurityScope` logs `The file couldn't be opened because it isn't in the correct format`.
- App Services and Automator Quick Action fallbacks were tested. They register in Finder Services, but Finder does not insert them into the background right-click menu for this iCloud/File Provider folder.
- A diagnostic unsandboxed Finder extension build did not register with PlugInKit, so the extension must remain sandboxed.
- The broad `com.apple.security.temporary-exception.files.absolute-path.read-write = /` entitlement was tested. It is riskier than a narrow entitlement but remains useful for local GitHub builds because direct sandbox writes to cloud-backed `Documents` can otherwise fail before the Finder-mediated AppleScript fallback runs.
- Current conclusion: with public Finder Sync behavior on this Mac, native Finder background context menu insertion works in local folders but is not called in this iCloud/File Provider folder. A true right-click workaround would require a separate Accessibility/Input Monitoring helper that shows its own menu, not a native Finder menu item.

Changed in `v1.1.1` on 2026-05-18:

- The large content heading was removed from the main app window because it duplicated the macOS title bar and could be clipped by the title bar on real systems.
- The window title is now set as `Mac Create File v <CFBundleShortVersionString>`, with an `NSViewRepresentable` applying the title to the attached `NSWindow`, so the app name and version appear in the top window chrome instead of inside the content.
- The main content now uses explicit top padding so the subtitle and controls start below the macOS title bar instead of sliding underneath it.

Changed on 2026-05-23:

- Replaced the separate `Enable Finder Extension` and `Disable Finder Extension` buttons with one `Mac Create File Extension` switch in the main app.
- The switch runs the same `pluginkit -a` / `pluginkit -e use` enable flow and `pluginkit -e ignore` disable flow that the old buttons used, then restarts Finder and refreshes `FIFinderSyncController.isExtensionEnabled`.
- The app now checks Finder Sync status on launch, so it no longer tells the user to enable the extension when macOS already reports it enabled.
- The static bottom instruction about System Settings was removed. Extension Settings guidance is now shown only when the extension is disabled, when macOS still requires manual approval, or immediately after the user clicks `Open Extension Settings`.
- Secondary actions now use neutral button styling so the active window no longer makes every action look like the primary blue control.

Changed in `v1.1.3` on 2026-05-23:

- Added a localized `Show in Dock` switch under the Finder extension switch in the main app.
- The switch stores `showInDock` in `UserDefaults` and applies `.regular` or `.accessory` through `NSApp.setActivationPolicy`.
- The default remains `Show in Dock = enabled` so existing users see the app in the Dock until they explicitly turn it off.
- When disabled, the app can still be opened from Applications, Finder, or Spotlight, but it does not keep a Dock icon.

Changed in `v1.1.4` on 2026-05-23:

- Restyled the main app's `Mac Create File Extension` and `Show in Dock` toggles as one compact settings group.
- Removed the redundant enabled/disabled subtitle from each toggle row so the switch itself is the only state indicator.
- Added a single separator between the two toggle rows and reduced the main window height after removing the extra vertical space.

Changed in `v1.1` on 2026-05-18:

- The main app title area now shows the app version from `CFBundleShortVersionString`, so the visible window title tracks release metadata.
- `Enable Finder Extension` now checks `FIFinderSyncController.isExtensionEnabled` after registering/enabling the extension. If macOS still requires confirmation, the app opens Extension Settings automatically and explains that the user must enable the Finder extension there.
- README instructions now document the real macOS permission boundary: the app can register the extension and open the correct settings screen, but macOS still requires user approval for the Finder extension toggle when prompted.
- README instructions now include a dedicated cloud/File Provider section explaining that toolbar usage is required in cloud-backed folders where Finder does not call the background right-click extension menu.
- Added the Finder Sync toolbar item by implementing `toolbarItemName`, `toolbarItemToolTip`, and `toolbarItemImage`.
- The extension now serves the same menu for `FIMenuKind.toolbarItemMenu` as for the context-menu paths. Apple documents that toolbar menu requests are made even when the selected/targeted Finder item is outside the extension's monitored folders, so this is the best native Finder Sync path for cloud folders where the background right-click menu is not called.
- Toolbar and context-menu requests now log selected URLs, targeted URL, and resolved menu target. Use `tail -100 ~/Library/Containers/com.sdenkrua.MacCreateFileApp.FinderExtension/Data/Library/Logs/MacCreateFileApp.log` after opening the toolbar menu to confirm which folder Finder supplied.
- If the toolbar menu request does not include a target, the selected action asks Finder again at action time. The previously tested `beginObservingDirectory` fallback was intentionally not used because multiple open Finder windows can make the last observed folder unrelated to the toolbar window.
- Removed the `Allowed Folders` UI and bookmark path because it did not make Finder call `menu(for:)` for the tested iCloud/File Provider background context menu.
- Removed the app `NSServices` fallback because it added a second system integration path and could create duplicate Finder/system menu entries.
- Kept `Entitlements-App.plist` as an empty entitlement file so the app bundle can still be signed while avoiding the sandbox restriction that previously blocked `pluginkit` extension registration.
- Replaced custom-drawn menu icons with native SF Symbols: `doc` for `Create File` and `doc.on.doc` for `Copy Path`.
- The extension keeps the temporary absolute-path read/write entitlement so direct creation in cloud-backed folders can succeed without depending on Automation permission. AppleScript remains only as a fallback path.

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
VERSION=1.1.4 scripts/package_release.sh
```

## Release Shape

The project should release:

```text
MacCreateFile-<version>-mac-arm64.dmg
```

The DMG should contain:

```text
Mac Create File.app
Applications
uninstall.command
```

Use the DMG format for releases by default. Do not publish `.zip` releases unless explicitly requested.
