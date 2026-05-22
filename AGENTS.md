# AGENTS.md — MacCreateFileApp

## User Rules

- Do not start code edits without explicit user permission.
- Reading files and running diagnostics is allowed.
- Before code changes, provide a clear implementation plan and ask for permission.
- After code changes, update documentation and changelog.
- Keep fixes practical and based on real diagnostics. Do not guess.
- Build/release artifacts are `.dmg` installer images. Do not publish `.zip` releases unless explicitly requested.

## Project Summary

MacCreateFileApp is a native macOS utility that adds a Finder right-click menu for creating files.

Architecture:

- Main app: `Sources/MacCreateFileApp/MacCreateFileApp.swift`
- Finder Sync extension: `Sources/MacCreateFileFinderExtension/FinderSync.swift`
- Embedded minimal Office/PDF templates: `Sources/MacCreateFileFinderExtension/MinimalFiles.swift`
- App strings: `Resources/*.lproj/Localizable.strings`
- Finder menu strings: `ExtensionResources/*.lproj/Localizable.strings`
- Build script: `scripts/build_app.sh`
- Release package script: `scripts/package_release.sh`

Current behavior:

- The release package is a `.dmg` containing `Mac Create File.app`, an `Applications` shortcut, and `uninstall.command`.
- The Finder extension is registered and enabled with `pluginkit`.
- File creation uses explicit Objective-C selectors per file type.
- Diagnostics are written to `~/Library/Logs/MacCreateFileApp.log`.

## Important PlugInKit Notes

macOS manages Finder Sync extensions separately from the `.app` bundle.

Deleting `Mac Create File.app` does not always remove the Finder menu immediately because:

- PlugInKit can keep the extension registered.
- Finder can cache extension menus.
- AppCleaner or manual deletion may remove files but not disable the extension first.

Correct disable flow:

```sh
pluginkit -e ignore -i com.sdenkrua.MacCreateFileApp.FinderExtension
killall Finder
```

Optional cleanup:

```sh
rm -rf "$HOME/Library/Application Scripts/com.sdenkrua.MacCreateFileApp.FinderExtension"
rm -rf "$HOME/Library/Containers/com.sdenkrua.MacCreateFileApp.FinderExtension"
rm -f "$HOME/Library/Logs/MacCreateFileApp.log"
killall cfprefsd
```

Diagnostics:

```sh
pluginkit -m -A | grep -i "MacCreate"
pluginkit -m -v -i com.sdenkrua.MacCreateFileApp.FinderExtension
tail -100 "$HOME/Library/Logs/MacCreateFileApp.log"
```

PlugInKit status markers:

- `+` means enabled/active.
- `-` means ignored/disabled.

## Known Follow-Up Work

Implemented uninstall-flow pieces:

- Keep the `Disable Finder Extension` button working.
- Keep `scripts/uninstall.command` executable and included in release `.dmg`.
- Update README install/uninstall sections whenever PlugInKit behavior changes.
- Add release notes for uninstall-flow changes.

Suggested uninstall script behavior:

```sh
#!/bin/bash
set -e

pluginkit -e ignore -i com.sdenkrua.MacCreateFileApp.FinderExtension || true
killall Finder || true

rm -rf "$HOME/Library/Application Scripts/com.sdenkrua.MacCreateFileApp.FinderExtension"
rm -rf "$HOME/Library/Containers/com.sdenkrua.MacCreateFileApp.FinderExtension" 2>/dev/null || true
rm -f "$HOME/Library/Logs/MacCreateFileApp.log"
rm -rf "$HOME/Library/Application Support/MacCreateFileApp"
killall cfprefsd || true
```

## Verification Checklist

After code changes:

```sh
scripts/verify_project.sh
VERSION=<version> scripts/package_release.sh
codesign --verify --deep --strict --verbose=2 "dist/Mac Create File.app"
hdiutil verify "dist/MacCreateFile-<version>-mac-<arch>.dmg"
pluginkit -m -v -i com.sdenkrua.MacCreateFileApp.FinderExtension
```

For file creation tests, use:

```sh
open "$HOME/Downloads/Тест"
tail -100 "$HOME/Library/Logs/MacCreateFileApp.log"
```

Office template validation:

```sh
unzip -t path/to/file.docx
unzip -t path/to/file.xlsx
unzip -t path/to/file.pptx
```
