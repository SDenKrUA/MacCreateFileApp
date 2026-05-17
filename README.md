# Mac Create File

Mac Create File is a macOS utility that adds a Finder right-click menu for creating new files in the current folder. It is built from scratch as a small native Swift app with a Finder Sync extension.

## Features

- Adds a `Create File` submenu to Finder context menus.
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

1. Download the latest `.zip` from GitHub Releases.
2. Unzip it.
3. Move `Mac Create File.app` to `Applications`.
4. Open `Applications/Mac Create File.app`.
5. Click `Enable Finder Extension`.
6. Click `Open Extension Settings` and enable `Mac Create File Finder Extension` if macOS asks for manual confirmation.
7. Restart Finder from the app, or log out and back in.
8. Right-click inside a Finder folder and choose `Create File`.

macOS does not allow third-party apps to silently enable Finder extensions in every case. Manual confirmation in System Settings may be required.

## Uninstall

Recommended:

1. Open `Mac Create File.app`.
2. Click `Uninstall Completely`.
3. Move `Mac Create File.app` to Trash.

This disables the Finder extension, restarts Finder, and removes support files. The app does not delete itself automatically.

The release zip also includes `uninstall.command` as a fallback. Use it if the app was already deleted or cannot be opened:

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
VERSION=1.0.22 scripts/package_release.sh
```

Release artifacts are created in `dist/`:

```text
MacCreateFile-1.0.17-mac-<arch>.zip
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

MIT. No external app code was copied into this project.
