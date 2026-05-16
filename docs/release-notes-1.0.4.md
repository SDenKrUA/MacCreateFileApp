# Mac Create File 1.0.4

This release fixes Finder submenu items that appeared visually but did not invoke the file creation action.

## What Changed

- Each file type now has a dedicated Objective-C action selector.
- Finder Sync no longer depends on `representedObject` from menu items.
- Menu item targets are left to Finder Sync, matching the standard extension dispatch path.

## Install

1. Download `MacCreateFile-1.0.4-mac-arm64.zip`.
2. Unzip it.
3. Move `Mac Create File.app` to `Applications`.
4. Open the app and click `Enable Finder Extension`.
5. Right-click inside a Finder folder and choose `Create File`.
