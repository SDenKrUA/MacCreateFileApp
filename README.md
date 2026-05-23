# Mac Create File

Mac Create File is a macOS utility that adds Finder menus for creating new files in the current folder. It is built from scratch as a small native Swift app with a Finder Sync extension.

## Features

- Adds a `Create File` submenu to Finder context menus.
- Adds a Finder toolbar button with the same menu for folders where macOS does not show third-party right-click extension items.
- Creates common file types: `txt`, `pdf`, `docx`, `xlsx`, and `pptx`.
- Uses bundled blank templates for `pdf`, `docx`, `xlsx`, and `pptx` for better compatibility with apps such as Keynote, PowerPoint, Word, and Excel.
- Adds an `Apple iWork` submenu for Pages (`pages`), Numbers (`numbers`), and Keynote (`key`) files.
- Adds a nested `Developer Types` submenu for `md`, `rtf`, `csv`, `json`, `html`, `css`, `js`, `py`, `swift`, and `sh`.
- Avoids overwriting existing files by automatically using names like `New Text File 2.txt`.
- Selects the newly created file in Finder.
- Copies selected Finder item paths.
- Opens Terminal in the current Finder folder.
- Includes English and Ukrainian localizations.

## Requirements

- macOS 13 or newer.
- Full Xcode or Command Line Tools with the macOS SDK for local builds.

## Install

1. Download the latest `.dmg` from GitHub Releases.
2. Open the `.dmg`.
3. Drag `Mac Create File.app` to the `Applications` folder in the DMG window.
4. Open `Applications/Mac Create File.app`.
5. Turn on the `Mac Create File Extension` switch.
6. If macOS still requires manual confirmation, open Extension Settings and enable `Mac Create File` under `Extensions > File Providers`.
7. Restart Finder from the app, or log out and back in.
8. Right-click inside a Finder folder and choose `Create File`.
9. Optional: in Finder, open toolbar customization and drag `Mac Create File` into the toolbar.

macOS does not allow third-party apps to silently grant every Finder extension permission. Mac Create File registers and requests the extension, shows the current extension state in the app switch, opens the settings screen when requested, and then waits for the user-approved macOS toggle when the system requires it.

## Cloud Folders and Finder Toolbar

Some iCloud Drive, OneDrive, Dropbox, Google Drive, and other File Provider-backed folders do not always show third-party Finder extension items in the background right-click menu. This is controlled by Finder/macOS, not by Mac Create File.

For those folders, use the Finder toolbar button:

1. Open Finder.
2. Choose `View > Customize Toolbar`.
3. Drag `Mac Create File` into the Finder toolbar.
4. Open the cloud-backed folder.
5. Click the `Mac Create File` toolbar button and choose the file type.

File creation in these cloud-backed folders is expected to work from the toolbar menu even when the right-click background menu is missing.

## Uninstall

Recommended:

1. Open `Mac Create File.app`.
2. Click `Uninstall Completely`.
3. Move `Mac Create File.app` to Trash.

This disables the Finder extension, restarts Finder, and removes support files. The app does not delete itself automatically.

The release DMG also includes `uninstall.command` as a fallback. Use it if the app was already deleted or cannot be opened:

```sh
./uninstall.command
```

macOS may keep some sandbox container metadata protected after uninstall. That does not keep the Finder menu active once the extension is disabled.

If the Finder menu remains after deleting the app, run:

```sh
pluginkit -e ignore -i com.sdenkrua.MacCreateFileApp.FinderExtension
killall Finder
```

## Gatekeeper Notice

Local builds are ad-hoc signed by default and are not Apple-notarized. On first launch, macOS may block the app with an unidentified developer warning.

To open it:

1. Right-click `Mac Create File.app`.
2. Choose `Open`.
3. Confirm `Open` in the dialog.

You can also allow it in `System Settings > Privacy & Security`.

## Build Locally

```sh
scripts/build_app.sh
```

The app is created at:

```text
dist/Mac Create File.app
```

To install a local build:

```sh
scripts/install_local.sh
```

## Package a Release

```sh
VERSION=1.1.5 scripts/package_release.sh
```

Release artifacts are created in `dist/`:

```text
MacCreateFile-1.1.5-mac-<arch>.dmg
```

## Signing

The build script uses ad-hoc signing by default:

```sh
scripts/build_app.sh
```

To sign with a Developer ID certificate:

```sh
SIGN_IDENTITY="Developer ID Application: Your Name (TEAMID)" scripts/package_release.sh
```

Apple notarization is not automated yet.

## How It Works

Finder context menu integration is provided by a Finder Sync extension. The extension registers Finder's root directory as its monitored scope so the menu can appear throughout Finder. When a menu item is selected, the extension creates the requested file in the targeted folder and asks Finder to reveal it.

## Languages

The app includes:

- English: `en.lproj`
- Ukrainian: `uk.lproj`

macOS selects the language based on the user's system language preferences.

## License

License: MIT
This project was independently implemented in Swift. It may share a similar general purpose with other Finder file-creation utilities, but no external application source code was copied into this repository.
