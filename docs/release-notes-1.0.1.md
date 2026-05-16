# Mac Create File 1.0.1

This release fixes Finder extension discovery and changes the downloadable package to a `.zip` containing `Mac Create File.app`.

## What Changed

- The app now registers its bundled Finder extension before enabling it.
- The Finder extension is built as a proper app-extension executable.
- Added extension entitlements for Finder integration.
- The app restarts Finder after enabling the extension.
- Release downloads now use `.zip` instead of `.dmg`.

## Install

1. Download `MacCreateFile-1.0.1-mac-arm64.zip`.
2. Unzip it.
3. Move `Mac Create File.app` to `Applications`.
4. Open the app.
5. Click `Enable Finder Extension`.
6. If macOS asks for confirmation, open Extension Settings and enable `Mac Create File Finder Extension`.
7. Right-click inside a Finder folder and choose `Create File`.
