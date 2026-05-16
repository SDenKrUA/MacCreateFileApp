# Mac Create File 1.0.2

This release fixes the `match: unauthorized discovery flag (PKDiscoverAll)` error shown after pressing `Enable Finder Extension`.

## What Changed

- The main app is no longer sandboxed, so it can run the required `pluginkit` registration and enable commands.
- Removed the forbidden `pluginkit -m` discovery call from the app button flow.
- The Finder extension remains sandboxed and keeps its Finder integration entitlements.

## Install

1. Download `MacCreateFile-1.0.2-mac-arm64.zip`.
2. Unzip it.
3. Move `Mac Create File.app` to `Applications`.
4. Open the app.
5. Click `Enable Finder Extension`.
6. If macOS asks for confirmation, open Extension Settings and enable `Mac Create File Finder Extension`.
7. Right-click inside a Finder folder and choose `Create File`.
