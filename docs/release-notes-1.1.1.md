# Mac Create File 1.1.1

## Fixed

- Moved the app name and version into the macOS window title bar as `Mac Create File v 1.1.1`.
- Removed the large duplicate heading and separate version line from the main window content.
- Fixed the visual clipping caused by the in-window heading sitting too close to the title bar.

## Changed

- Release packaging now uses a `.dmg` installer image with `Mac Create File.app`, an `Applications` shortcut, and `uninstall.command`.
- Added explicit top padding so the main content starts below the macOS title bar.
