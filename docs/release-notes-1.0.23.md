# Mac Create File 1.0.23

## Added

- Added `Allowed Folders` in the main app.
- Added quick buttons for Desktop, Documents, iCloud Drive, and CloudStorage.
- Added custom folder selection through the macOS folder picker.
- Stored allowed folder bookmarks in the Finder extension container instead of using an App Group.

## Changed

- Finder extension now adds allowed folders to monitored roots in addition to default roots.
- If a security-scoped bookmark cannot be resolved, the extension logs the error and uses the stored path as a monitored-folder fallback.
