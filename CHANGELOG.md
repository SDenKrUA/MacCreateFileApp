# Changelog

## 1.0.23 - 2026-05-17

- Added an `Allowed Folders` section to the main app for cloud/protected folders.
- Added folder bookmark storage in the Finder extension container without reintroducing App Group sharing.
- Finder extension now loads allowed folders, starts security-scoped access when available, and adds them to monitored roots.
- Kept a stored-path fallback for diagnostics and monitoring when a bookmark cannot be resolved.

## 1.0.22 - 2026-05-17

- Added the real user home folder as a Finder Sync monitored root so cloud-backed subfolders such as `Documents/Тест` are observed.
- Added Finder Sync diagnostics for observed folders and menu requests.
- Fixed file creation target resolution to prefer Finder's `targetedURL()` over stale selected sidebar/search URLs.

## 1.0.21 - 2026-05-17

- Fixed Finder Sync cloud-folder monitoring to use the real current user's home directory instead of the extension sandbox home.
- Kept extension logs inside the extension container so diagnostics remain writable from the sandbox.
- Added a Finder AppleScript duplicate fallback for Desktop, Documents, iCloud Drive, OneDrive, and other folders where direct sandbox writes can fail.
- Added localized Finder fallback error text.

## 1.0.20 - 2026-05-17

- Redrew the `Create File` and `Copy Path` document icons with larger folded corners and less visual overlap.
- Changed the `Copy Path` icon so the back document is only a partial behind-document hint, closer to Finder's native copy glyph.
- Added explicit Finder monitored roots for Desktop, Documents, iCloud Drive, `Mobile Documents`, `CloudStorage`, and installed CloudStorage providers such as OneDrive.
- Logged the monitored Finder roots at extension startup to make cloud-folder diagnostics easier.

## 1.0.19 - 2026-05-17

- Refined custom document menu icons to better match native Finder icon geometry.
- Increased the folded document corner size so it reads less like a filled black corner.
- Changed the `Copy Path` icon to draw the rear document as a partial behind-document outline.
- Reduced custom icon stroke weight again for a lighter native feel.

## 1.0.18 - 2026-05-17

- Refined Finder menu icon geometry to better match native macOS menu icons.
- Made menu icon strokes thinner and added more inner spacing.
- Moved the plus mark inside the `Create File` document icon for better readability.
- Updated Ukrainian menu text from `Terminal` to `Термінал`.

## 1.0.17 - 2026-05-17

- Added an `Apple iWork` submenu under `Create File`.
- Added Pages, Numbers, and Keynote document creation using bundled blank templates.

## 1.0.16 - 2026-05-17

- Replaced generated minimal `pdf`, `docx`, `xlsx`, and `pptx` data with bundled blank template files.
- Removed `MinimalFiles.swift` and the base64/minimal OOXML fallback files.
- PowerPoint, Word, Excel, and PDF creation now copies real blank documents from `ExtensionResources/Templates`.

## 1.0.15 - 2026-05-17

- Added an `Uninstall Completely` button to the main app.
- The uninstall flow disables the Finder extension, restarts Finder, removes support files, and clears legacy App Group leftovers.
- Added a confirmation dialog and localized uninstall status messages.

## 1.0.14 - 2026-05-17

- Replaced SF Symbol menu icons with custom-drawn outline icons.
- Menu icons now choose a light or dark stroke color from the current macOS appearance.
- Fixed black Finder extension menu icons being unreadable in dark mode.

## 1.0.13 - 2026-05-16

- Made Finder menu icons template images so they adapt to light and dark mode.
- Added icons to `Copy Path` and `Open Terminal Here`.
- Changed `Open Terminal Here` to use `/usr/bin/open -a Terminal` instead of AppleScript.
- Added localized error text and logs for Terminal launch failures.

## 1.0.12 - 2026-05-16

- Added a generated macOS app icon with a document and plus symbol.
- Added a `doc.badge.plus` icon to the Finder `Create File` menu item.
- Updated the build script to generate the app `.icns` during packaging.

## 1.0.11 - 2026-05-16

- Removed the `Show developer file types` toggle from the main app.
- Added a permanent `Developer Types` submenu under the Finder `Create File` menu.
- Removed developer-toggle settings reads/writes, so changing developer type visibility no longer requires restarting Finder.

## 1.0.10 - 2026-05-16

- Fixed developer file type visibility without using App Group entitlements.
- The main app now writes the toggle into the Finder extension preferences inside the extension sandbox container.
- The Finder extension now reads the toggle directly from its own preferences file, avoiding the macOS App Group privacy warning and preferences daemon cache issues.
- The main app migrates the previous developer-toggle value from the old Application Support settings file.

## 1.0.9 - 2026-05-16

- Removed App Group entitlements to avoid macOS privacy warnings after toggling developer file types.
- Restored shared developer-toggle storage to `~/Library/Application Support/MacCreateFileApp/Settings.plist`.
- Kept Finder extension access through its existing absolute-path temporary exception.

## 1.0.8 - 2026-05-16

- Fixed `Show developer file types` toggle sync between the main app and Finder extension.
- Switched shared setting storage to App Group `UserDefaults` (`group.com.sdenkrua.MacCreateFileApp`).
- Added app-side entitlements for App Group access and updated extension entitlements.
- Updated uninstall script to remove App Group settings files.

## 1.0.7 - 2026-05-16

- Simplified the default Create File submenu to Text, PDF, Word, Excel, and PowerPoint.
- Added a `Show developer file types` toggle in the main app.
- Developer file types are hidden by default and can be shown when needed.
- Added a shared settings file read by the main app and Finder extension.

## 1.0.6 - 2026-05-16

- Removed the separator after the `Create File` menu item because Finder rendered it as an oversized blank space.

## 1.0.5 - 2026-05-16

- Added a `Disable Finder Extension` button to the main app.
- Added `scripts/uninstall.command` for disabling the Finder extension and cleaning support files.
- Updated release packaging so the zip contains both `Mac Create File.app` and `uninstall.command`.
- Added uninstall documentation to English and Ukrainian READMEs.
- Added project/agent notes for future maintenance.

## 1.0.4 - 2026-05-16

- Replaced the generic menu action plus represented object with explicit Objective-C selectors for every file type.
- Removed explicit menu item targets so Finder Sync dispatches actions to the extension principal object.
- Fixed menu clicks that displayed the submenu but did not invoke file creation.

## 1.0.3 - 2026-05-16

- Fixed silent failures when choosing a file type from the Finder submenu.
- Added Finder insertion-location fallback when Finder Sync does not provide `targetedURL` or `selectedItemURLs`.
- Added visible localized errors instead of returning silently.
- Switched file creation to `FileManager.createFile`.
- Added extension-side diagnostics to `~/Library/Logs/MacCreateFileApp.log` and system log.

## 1.0.2 - 2026-05-16

- Removed the sandbox entitlement from the main app so `pluginkit` commands can run without `PKDiscoverAll` authorization errors.
- Removed the app-side `pluginkit -m` discovery check after enabling the extension.
- Kept the Finder extension sandboxed with its Finder-specific entitlements.

## 1.0.1 - 2026-05-16

- Changed release packaging to produce a `.zip` containing `Mac Create File.app` instead of a `.dmg`.
- Fixed Finder extension registration by registering the bundled `.appex` before enabling it.
- Built the Finder extension as a macOS app-extension executable instead of a shared library.
- Added app and extension entitlements for macOS extension discovery and Finder actions.
- Added clearer success and fallback status messages after enabling the extension.
- Restart Finder automatically after enabling the extension.

## 1.0.0 - 2026-05-16

- Created a new macOS Finder file-creation utility from scratch.
- Added a native Swift main app for extension setup and Finder restart actions.
- Added a Finder Sync extension with a `Create File` submenu.
- Added file creation for `txt`, `md`, `rtf`, `csv`, `json`, `html`, `css`, `js`, `py`, `swift`, `sh`, `pdf`, `docx`, `xlsx`, and `pptx`.
- Added automatic duplicate-name handling.
- Added Finder reveal after file creation.
- Added Copy Path and Open Terminal Here actions.
- Added English and Ukrainian app localizations.
- Added English and Ukrainian Finder menu localizations.
- Added local build, install, verification, and release packaging scripts.
- Added English and Ukrainian documentation.
- Added MIT license and repository ignore rules.
