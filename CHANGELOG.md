# Changelog

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
