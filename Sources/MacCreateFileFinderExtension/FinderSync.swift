import AppKit
import FinderSync

@objc(FinderSync)
final class FinderSync: FIFinderSync {
    private let logFileURL = URL(fileURLWithPath: NSHomeDirectoryForUser(NSUserName()) ?? NSHomeDirectory())
        .appendingPathComponent("Library/Logs/MacCreateFileApp.log")

    private let fileTypes: [FileTemplate] = [
        .init(id: "txt", extensionName: "txt", nameKey: "file.text", baseNameKey: "filename.text", content: .text("")),
        .init(id: "pdf", extensionName: "pdf", nameKey: "file.pdf", baseNameKey: "filename.pdf", content: .data(MinimalFiles.pdf)),
        .init(id: "docx", extensionName: "docx", nameKey: "file.word", baseNameKey: "filename.word", content: .data(MinimalFiles.docx)),
        .init(id: "xlsx", extensionName: "xlsx", nameKey: "file.excel", baseNameKey: "filename.excel", content: .data(MinimalFiles.xlsx)),
        .init(id: "pptx", extensionName: "pptx", nameKey: "file.powerpoint", baseNameKey: "filename.powerpoint", content: .data(MinimalFiles.pptx))
    ]

    private let developerFileTypes: [FileTemplate] = [
        .init(id: "md", extensionName: "md", nameKey: "file.markdown", baseNameKey: "filename.markdown", content: .text("# New Document\n")),
        .init(id: "rtf", extensionName: "rtf", nameKey: "file.rtf", baseNameKey: "filename.rtf", content: .text("{\\rtf1\\ansi\\deff0\n}\n")),
        .init(id: "csv", extensionName: "csv", nameKey: "file.csv", baseNameKey: "filename.csv", content: .text("")),
        .init(id: "json", extensionName: "json", nameKey: "file.json", baseNameKey: "filename.json", content: .text("{\n  \n}\n")),
        .init(id: "html", extensionName: "html", nameKey: "file.html", baseNameKey: "filename.html", content: .text("<!doctype html>\n<html lang=\"en\">\n<head>\n  <meta charset=\"utf-8\">\n  <title>New Page</title>\n</head>\n<body>\n</body>\n</html>\n")),
        .init(id: "css", extensionName: "css", nameKey: "file.css", baseNameKey: "filename.css", content: .text("")),
        .init(id: "js", extensionName: "js", nameKey: "file.javascript", baseNameKey: "filename.javascript", content: .text("")),
        .init(id: "py", extensionName: "py", nameKey: "file.python", baseNameKey: "filename.python", content: .text("")),
        .init(id: "swift", extensionName: "swift", nameKey: "file.swift", baseNameKey: "filename.swift", content: .text("import Foundation\n\n")),
        .init(id: "sh", extensionName: "sh", nameKey: "file.shell", baseNameKey: "filename.shell", content: .text("#!/bin/sh\n"))
    ]

    override init() {
        super.init()
        FIFinderSyncController.default().directoryURLs = [URL(fileURLWithPath: "/")]
    }

    override func menu(for menuKind: FIMenuKind) -> NSMenu? {
        let menu = NSMenu(title: localized("menu.root"))

        let createMenu = NSMenu(title: localized("menu.createFile"))
        for template in visibleFileTypes {
            let item = NSMenuItem(
                title: localized(template.nameKey),
                action: actionSelector(for: template.id),
                keyEquivalent: ""
            )
            createMenu.addItem(item)
        }

        let createItem = NSMenuItem(title: localized("menu.createFile"), action: nil, keyEquivalent: "")
        createItem.submenu = createMenu
        menu.addItem(createItem)

        let copyPathItem = NSMenuItem(title: localized("menu.copyPath"), action: #selector(copyPath(_:)), keyEquivalent: "")
        menu.addItem(copyPathItem)

        let terminalItem = NSMenuItem(title: localized("menu.openTerminal"), action: #selector(openTerminal(_:)), keyEquivalent: "")
        menu.addItem(terminalItem)

        return menu
    }

    @objc(createTextFile:)
    func createTextFile(_ sender: NSMenuItem) {
        createFile(withID: "txt")
    }

    @objc(createMarkdownFile:)
    func createMarkdownFile(_ sender: NSMenuItem) {
        createFile(withID: "md")
    }

    @objc(createRichTextFile:)
    func createRichTextFile(_ sender: NSMenuItem) {
        createFile(withID: "rtf")
    }

    @objc(createCSVFile:)
    func createCSVFile(_ sender: NSMenuItem) {
        createFile(withID: "csv")
    }

    @objc(createJSONFile:)
    func createJSONFile(_ sender: NSMenuItem) {
        createFile(withID: "json")
    }

    @objc(createHTMLFile:)
    func createHTMLFile(_ sender: NSMenuItem) {
        createFile(withID: "html")
    }

    @objc(createCSSFile:)
    func createCSSFile(_ sender: NSMenuItem) {
        createFile(withID: "css")
    }

    @objc(createJavaScriptFile:)
    func createJavaScriptFile(_ sender: NSMenuItem) {
        createFile(withID: "js")
    }

    @objc(createPythonFile:)
    func createPythonFile(_ sender: NSMenuItem) {
        createFile(withID: "py")
    }

    @objc(createSwiftFile:)
    func createSwiftFile(_ sender: NSMenuItem) {
        createFile(withID: "swift")
    }

    @objc(createShellScript:)
    func createShellScript(_ sender: NSMenuItem) {
        createFile(withID: "sh")
    }

    @objc(createPDFDocument:)
    func createPDFDocument(_ sender: NSMenuItem) {
        createFile(withID: "pdf")
    }

    @objc(createWordDocument:)
    func createWordDocument(_ sender: NSMenuItem) {
        createFile(withID: "docx")
    }

    @objc(createExcelWorkbook:)
    func createExcelWorkbook(_ sender: NSMenuItem) {
        createFile(withID: "xlsx")
    }

    @objc(createPowerPointPresentation:)
    func createPowerPointPresentation(_ sender: NSMenuItem) {
        createFile(withID: "pptx")
    }

    private func createFile(withID id: String) {
        guard let template = allFileTypes.first(where: { $0.id == id }) else {
            writeLog("createFile failed: missing template id=\(id)")
            showError(FinderCreateError.missingTemplate)
            return
        }

        writeLog("createFile selected type=\(template.extensionName)")

        guard let directory = targetDirectory() else {
            writeLog("createFile failed: no target directory from Finder")
            showError(FinderCreateError.missingTargetDirectory)
            return
        }

        writeLog("createFile target directory=\(directory.path)")

        let destination = uniqueURL(in: directory, baseName: localized(template.baseNameKey), extensionName: template.extensionName)
        writeLog("createFile destination=\(destination.path)")

        do {
            try template.content.write(to: destination)
            if template.extensionName == "sh" {
                try FileManager.default.setAttributes([.posixPermissions: 0o755], ofItemAtPath: destination.path)
            }
            writeLog("createFile success path=\(destination.path)")
            NSWorkspace.shared.activateFileViewerSelecting([destination])
        } catch {
            writeLog("createFile failed: \(error.localizedDescription)")
            showError(error)
        }
    }

    @objc(copyPath:)
    func copyPath(_ sender: NSMenuItem) {
        let urls = FIFinderSyncController.default().selectedItemURLs() ?? []
        let fallback = FIFinderSyncController.default().targetedURL().map { [$0] } ?? []
        let paths = (urls.isEmpty ? fallback : urls).map(\.path).joined(separator: "\n")

        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(paths, forType: .string)
    }

    @objc(openTerminal:)
    func openTerminal(_ sender: NSMenuItem) {
        guard let directory = targetDirectory() else { return }
        let script = "tell application \"Terminal\" to do script \"cd " + shellEscaped(directory.path) + "\""
        NSAppleScript(source: script)?.executeAndReturnError(nil)
    }

    private func targetDirectory() -> URL? {
        let selectedURLs = FIFinderSyncController.default().selectedItemURLs() ?? []
        if let selected = selectedURLs.first {
            writeLog("targetDirectory using selectedItemURLs first=\(selected.path)")
            return folderURL(for: selected)
        }

        if let targeted = FIFinderSyncController.default().targetedURL() {
            writeLog("targetDirectory using targetedURL=\(targeted.path)")
            return folderURL(for: targeted)
        }

        if let insertionLocation = finderInsertionLocation() {
            writeLog("targetDirectory using Finder insertion location=\(insertionLocation.path)")
            return folderURL(for: insertionLocation)
        }

        writeLog("targetDirectory failed: selectedItemURLs, targetedURL, and Finder insertion location are empty")
        return nil
    }

    private func actionSelector(for id: String) -> Selector {
        switch id {
        case "txt":
            return #selector(createTextFile(_:))
        case "md":
            return #selector(createMarkdownFile(_:))
        case "rtf":
            return #selector(createRichTextFile(_:))
        case "csv":
            return #selector(createCSVFile(_:))
        case "json":
            return #selector(createJSONFile(_:))
        case "html":
            return #selector(createHTMLFile(_:))
        case "css":
            return #selector(createCSSFile(_:))
        case "js":
            return #selector(createJavaScriptFile(_:))
        case "py":
            return #selector(createPythonFile(_:))
        case "swift":
            return #selector(createSwiftFile(_:))
        case "sh":
            return #selector(createShellScript(_:))
        case "pdf":
            return #selector(createPDFDocument(_:))
        case "docx":
            return #selector(createWordDocument(_:))
        case "xlsx":
            return #selector(createExcelWorkbook(_:))
        case "pptx":
            return #selector(createPowerPointPresentation(_:))
        default:
            return #selector(createTextFile(_:))
        }
    }

    private var visibleFileTypes: [FileTemplate] {
        SharedSettings.showDeveloperFileTypes ? fileTypes + developerFileTypes : fileTypes
    }

    private var allFileTypes: [FileTemplate] {
        fileTypes + developerFileTypes
    }

    private func folderURL(for url: URL) -> URL {
        var isDirectory: ObjCBool = false
        if FileManager.default.fileExists(atPath: url.path, isDirectory: &isDirectory), isDirectory.boolValue {
            return url
        }
        return url.deletingLastPathComponent()
    }

    private func uniqueURL(in directory: URL, baseName: String, extensionName: String) -> URL {
        var index = 1
        var candidate = directory.appendingPathComponent(baseName).appendingPathExtension(extensionName)

        while FileManager.default.fileExists(atPath: candidate.path) {
            index += 1
            candidate = directory.appendingPathComponent("\(baseName) \(index)").appendingPathExtension(extensionName)
        }

        return candidate
    }

    private func showError(_ error: Error) {
        let alert = NSAlert()
        alert.messageText = localized("error.createFailed")
        alert.informativeText = errorText(error)
        alert.alertStyle = .warning
        alert.runModal()
    }

    private func errorText(_ error: Error) -> String {
        guard let createError = error as? FinderCreateError else {
            return error.localizedDescription
        }

        switch createError {
        case .missingTemplate:
            return localized("error.missingTemplate")
        case .missingTargetDirectory:
            return localized("error.missingTargetDirectory")
        case .createFileReturnedFalse(let path):
            return String(format: localized("error.createReturnedFalse"), path)
        }
    }

    private func finderInsertionLocation() -> URL? {
        let source = """
        tell application "Finder"
            if (count of Finder windows) > 0 then
                set targetFolder to insertion location as alias
                return POSIX path of targetFolder
            end if
        end tell
        """

        var errorInfo: NSDictionary?
        let output = NSAppleScript(source: source)?.executeAndReturnError(&errorInfo)

        if let errorInfo {
            writeLog("finderInsertionLocation AppleScript error=\(errorInfo)")
        }

        guard let path = output?.stringValue, !path.isEmpty else {
            return nil
        }

        return URL(fileURLWithPath: path)
    }

    private func writeLog(_ message: String) {
        let timestamp = ISO8601DateFormatter().string(from: Date())
        let line = "[\(timestamp)] \(message)\n"
        NSLog("MacCreateFileApp: %@", message)

        do {
            try FileManager.default.createDirectory(
                at: logFileURL.deletingLastPathComponent(),
                withIntermediateDirectories: true
            )

            if FileManager.default.fileExists(atPath: logFileURL.path),
               let handle = try? FileHandle(forWritingTo: logFileURL) {
                defer { try? handle.close() }
                try handle.seekToEnd()
                if let data = line.data(using: .utf8) {
                    try handle.write(contentsOf: data)
                }
            } else {
                try line.write(to: logFileURL, atomically: true, encoding: .utf8)
            }
        } catch {
            NSLog("MacCreateFileApp: could not write log: %@", error.localizedDescription)
        }
    }

    private func localized(_ key: String) -> String {
        Bundle.main.localizedString(forKey: key, value: key, table: nil)
    }

    private func shellEscaped(_ path: String) -> String {
        "'" + path.replacingOccurrences(of: "'", with: "'\\''") + "'"
    }
}

struct FileTemplate {
    let id: String
    let extensionName: String
    let nameKey: String
    let baseNameKey: String
    let content: FileContent
}

enum FileContent {
    case text(String)
    case data(Data)

    func write(to url: URL) throws {
        let outputData: Data
        switch self {
        case .text(let text):
            outputData = Data(text.utf8)
        case .data(let fileData):
            outputData = fileData
        }

        guard FileManager.default.createFile(atPath: url.path, contents: outputData) else {
            throw FinderCreateError.createFileReturnedFalse(url.path)
        }
    }
}

enum FinderCreateError: LocalizedError {
    case missingTemplate
    case missingTargetDirectory
    case createFileReturnedFalse(String)

    var errorDescription: String? {
        switch self {
        case .missingTemplate:
            return "The selected file type could not be resolved."
        case .missingTargetDirectory:
            return "Finder did not provide a target folder. Open a Finder folder window and try right-clicking inside the file list area."
        case .createFileReturnedFalse(let path):
            return "The file could not be created at: \(path)"
        }
    }
}

enum SharedSettings {
    private static let developerFileTypesKey = "showDeveloperFileTypes"

    private static var settingsURL: URL {
        URL(fileURLWithPath: NSHomeDirectoryForUser(NSUserName()) ?? NSHomeDirectory())
            .appendingPathComponent("Library/Application Support/MacCreateFileApp/Settings.plist")
    }

    static var showDeveloperFileTypes: Bool {
        guard
            let data = try? Data(contentsOf: settingsURL),
            let plist = try? PropertyListSerialization.propertyList(from: data, format: nil) as? [String: Bool]
        else { return false }
        return plist[developerFileTypesKey] ?? false
    }
}
