# Mac Create File 1.0.5

This release adds a proper uninstall flow for the Finder extension.

## What Changed

- Added `Disable Finder Extension` in the main app.
- Added `uninstall.command` to the release zip.
- The uninstall script disables the Finder extension, restarts Finder, and removes support files.
- Updated English and Ukrainian uninstall instructions.
- Added maintainer notes in `AGENTS.md`, `docs/PROJECT_NOTES.md`, and `docs/UNINSTALL.md`.

## Install

1. Download `MacCreateFile-1.0.5-mac-arm64.zip`.
2. Unzip it.
3. Move `Mac Create File.app` to `Applications`.
4. Open the app and click `Enable Finder Extension`.

## Uninstall

1. Open `Mac Create File.app`.
2. Click `Disable Finder Extension`.
3. Move the app to Trash.

Or run:

```sh
./uninstall.command
```
