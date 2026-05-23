# Mac Create File 1.1.2

## Fixed

- The main app now checks the Finder Sync extension state on launch instead of always telling the user to enable it.
- Extension Settings guidance no longer says System Settings is open before the user opens it.
- Extension Settings guidance is no longer shown as a permanent bottom paragraph after the extension is already enabled.

## Changed

- Replaced separate `Enable Finder Extension` and `Disable Finder Extension` buttons with one `Mac Create File Extension` switch.
- The switch uses the same PlugInKit enable/disable commands as the old buttons, then restarts Finder and refreshes the displayed state.
- Secondary actions now use neutral button styling so they do not all appear as primary blue actions.
- The release artifact remains a `.dmg` installer image: `MacCreateFile-1.1.2-mac-arm64.dmg`.
