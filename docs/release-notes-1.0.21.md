# Mac Create File 1.0.21

## Fixed

- Fixed cloud-folder monitoring to use the real current user's home directory instead of the Finder extension sandbox home.
- Added a Finder duplicate fallback for Desktop, Documents, iCloud Drive, OneDrive, and other protected/cloud folders where direct sandbox writes can fail.
- Kept extension diagnostics in the extension container log path so logging remains reliable from the sandbox.

## Verification

- Verified the extension now logs real monitored roots such as `/Users/<name>/Desktop`, `/Users/<name>/Documents`, iCloud Drive, and CloudStorage provider folders.
- Verified Finder can duplicate a temporary file into `Documents/Тест`, the same mechanism used by the new fallback.
