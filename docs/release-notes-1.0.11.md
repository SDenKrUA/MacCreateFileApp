# Mac Create File 1.0.11

## Changed

- Removed the `Show developer file types` toggle from the main app.
- Added a permanent `Developer Types` submenu inside `Create File`.
- Main file types stay immediately visible: Text, PDF, Word, Excel, and PowerPoint.
- Developer file types are available one level deeper: Markdown, Rich Text, CSV, JSON, HTML, CSS, JavaScript, Python, Swift, and Shell Script.

## Why

- No Finder restart is needed to switch between basic and developer file types.
- No shared setting is needed between the app and Finder extension.
- This avoids both sandbox preference issues and App Group privacy prompts.

