# Mac Create File 1.0.22

## Fixed

- Added the real user home folder as a monitored Finder Sync root so cloud-backed subfolders are observed reliably.
- Fixed create-file target resolution to prefer the folder Finder reports under the cursor instead of stale selected sidebar/search URLs.
- Added Finder Sync diagnostics for observed folders and context-menu requests.

## Verification

- Verified Finder begins observing `~/Documents/Тест`.
- Verified Finder requests the extension menu with `targetedURL = ~/Documents/Тест`.
