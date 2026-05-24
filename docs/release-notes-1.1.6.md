# Mac Create File 1.1.6

## Fixed

- Kept Finder menu icons and the Finder toolbar icon on separate rendering paths so both light and dark mode stay readable.
- Re-applied the saved `Show in Dock` preference during launch so reinstalling the app does not leave the Dock icon visible when the toggle is off.
- Updated the local install script to quit a running old app process before replacing the app bundle.
- The release artifact remains a `.dmg` installer image: `MacCreateFile-1.1.6-mac-arm64.dmg`.

## Notes

- Finder menu icons use manually tinted SF Symbol images because Finder does not reliably tint menu icons in dark mode.
- The Finder toolbar icon remains a template SF Symbol so Finder can tint the toolbar button itself.
