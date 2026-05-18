# Mac Create File 1.1

## Added

- Added a Finder toolbar button for the Finder Sync extension.
- The toolbar button opens the same Mac Create File menu as the Finder extension context menu.
- Added toolbar diagnostics to the Finder extension container log for selected URLs, targeted URL, and resolved menu target.
- Added the app version under the `Mac Create File` title in the main window.

## Changed

- `Enable Finder Extension` now checks whether macOS reports the Finder Sync extension as enabled.
- If macOS still requires manual confirmation, the app opens Extension Settings automatically and tells the user to enable `Mac Create File Finder Extension` there.
- Updated English and Ukrainian README instructions for the real macOS permission flow.
- Expanded cloud-folder documentation for iCloud Drive, OneDrive, Dropbox, Google Drive, and other File Provider-backed folders where Finder may hide background right-click extension items.
- Replaced custom menu icons with native macOS SF Symbols for `Create File` and `Copy Path`.
- Updated the main app text to explain the toolbar option.

## Removed

- Removed the `Allowed Folders` UI and bookmark storage path because testing showed it did not make macOS call the Finder Sync background context menu in iCloud/File Provider folders.
- Removed the app `NSServices` fallback to prevent duplicate Finder/system menu entries.
- Removed unused App Group and bookmark entitlements.
- Kept the main app without sandbox entitlements so its `pluginkit` registration commands can keep working.
- Kept the Finder extension's temporary absolute-path read/write entitlement so cloud-backed folders can use direct file creation instead of depending on Automation permission.
