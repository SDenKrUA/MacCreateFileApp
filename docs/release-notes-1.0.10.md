# Mac Create File 1.0.10

## Fixed

- Developer file types now remain visible when the `Show developer file types` toggle is enabled.
- The toggle no longer uses App Group storage, avoiding the macOS privacy warning shown after right-clicking in Finder.

## Changed

- The main app writes `showDeveloperFileTypes` into the Finder extension preferences file inside the extension sandbox container.
- The Finder extension reads the toggle directly from its own preferences file to avoid preferences daemon cache issues.
- The main app migrates the previous toggle value from the old Application Support settings file.
