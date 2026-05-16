# Mac Create File 1.0.3

This release fixes silent failures after selecting a file type in Finder.

## What Changed

- Added a fallback to Finder's insertion location when Finder Sync does not provide the target folder.
- Added visible errors when the target folder cannot be resolved.
- Added diagnostics to `~/Library/Logs/MacCreateFileApp.log`.
- Switched file creation to `FileManager.createFile`.

## Install

1. Download `MacCreateFile-1.0.3-mac-arm64.zip`.
2. Unzip it.
3. Move `Mac Create File.app` to `Applications`.
4. Open the app and click `Enable Finder Extension`.
5. Right-click inside a Finder folder and choose `Create File`.
