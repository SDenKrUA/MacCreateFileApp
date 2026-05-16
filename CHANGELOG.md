# Changelog

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
