import AppKit
import FinderSync

final class FinderSync: FIFinderSync {
    private let fileTypes: [FileTemplate] = [
        .init(id: "txt", extensionName: "txt", nameKey: "file.text", baseNameKey: "filename.text", content: .text("")),
        .init(id: "md", extensionName: "md", nameKey: "file.markdown", baseNameKey: "filename.markdown", content: .text("# New Document\n")),
        .init(id: "rtf", extensionName: "rtf", nameKey: "file.rtf", baseNameKey: "filename.rtf", content: .text("{\\rtf1\\ansi\\deff0\n}\n")),
        .init(id: "csv", extensionName: "csv", nameKey: "file.csv", baseNameKey: "filename.csv", content: .text("")),
        .init(id: "json", extensionName: "json", nameKey: "file.json", baseNameKey: "filename.json", content: .text("{\n  \n}\n")),
        .init(id: "html", extensionName: "html", nameKey: "file.html", baseNameKey: "filename.html", content: .text("<!doctype html>\n<html lang=\"en\">\n<head>\n  <meta charset=\"utf-8\">\n  <title>New Page</title>\n</head>\n<body>\n</body>\n</html>\n")),
        .init(id: "css", extensionName: "css", nameKey: "file.css", baseNameKey: "filename.css", content: .text("")),
        .init(id: "js", extensionName: "js", nameKey: "file.javascript", baseNameKey: "filename.javascript", content: .text("")),
        .init(id: "py", extensionName: "py", nameKey: "file.python", baseNameKey: "filename.python", content: .text("")),
        .init(id: "swift", extensionName: "swift", nameKey: "file.swift", baseNameKey: "filename.swift", content: .text("import Foundation\n\n")),
        .init(id: "sh", extensionName: "sh", nameKey: "file.shell", baseNameKey: "filename.shell", content: .text("#!/bin/sh\n")),
        .init(id: "pdf", extensionName: "pdf", nameKey: "file.pdf", baseNameKey: "filename.pdf", content: .data(MinimalFiles.pdf)),
        .init(id: "docx", extensionName: "docx", nameKey: "file.word", baseNameKey: "filename.word", content: .data(MinimalFiles.docx)),
        .init(id: "xlsx", extensionName: "xlsx", nameKey: "file.excel", baseNameKey: "filename.excel", content: .data(MinimalFiles.xlsx)),
        .init(id: "pptx", extensionName: "pptx", nameKey: "file.powerpoint", baseNameKey: "filename.powerpoint", content: .data(MinimalFiles.pptx))
    ]

    override init() {
        super.init()
        FIFinderSyncController.default().directoryURLs = [URL(fileURLWithPath: "/")]
    }

    override func menu(for menuKind: FIMenuKind) -> NSMenu? {
        let menu = NSMenu(title: localized("menu.root"))

        let createMenu = NSMenu(title: localized("menu.createFile"))
        for template in fileTypes {
            let item = NSMenuItem(
                title: localized(template.nameKey),
                action: #selector(createFile(_:)),
                keyEquivalent: ""
            )
            item.target = self
            item.representedObject = template.id
            createMenu.addItem(item)
        }

        let createItem = NSMenuItem(title: localized("menu.createFile"), action: nil, keyEquivalent: "")
        createItem.submenu = createMenu
        menu.addItem(createItem)
        menu.addItem(.separator())

        let copyPathItem = NSMenuItem(title: localized("menu.copyPath"), action: #selector(copyPath(_:)), keyEquivalent: "")
        copyPathItem.target = self
        menu.addItem(copyPathItem)

        let terminalItem = NSMenuItem(title: localized("menu.openTerminal"), action: #selector(openTerminal(_:)), keyEquivalent: "")
        terminalItem.target = self
        menu.addItem(terminalItem)

        return menu
    }

    @objc private func createFile(_ sender: NSMenuItem) {
        guard
            let id = sender.representedObject as? String,
            let template = fileTypes.first(where: { $0.id == id }),
            let directory = targetDirectory()
        else { return }

        let destination = uniqueURL(in: directory, baseName: localized(template.baseNameKey), extensionName: template.extensionName)

        do {
            try template.content.write(to: destination)
            if template.extensionName == "sh" {
                try FileManager.default.setAttributes([.posixPermissions: 0o755], ofItemAtPath: destination.path)
            }
            NSWorkspace.shared.activateFileViewerSelecting([destination])
        } catch {
            showError(error)
        }
    }

    @objc private func copyPath(_ sender: NSMenuItem) {
        let urls = FIFinderSyncController.default().selectedItemURLs() ?? []
        let fallback = FIFinderSyncController.default().targetedURL().map { [$0] } ?? []
        let paths = (urls.isEmpty ? fallback : urls).map(\.path).joined(separator: "\n")

        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(paths, forType: .string)
    }

    @objc private func openTerminal(_ sender: NSMenuItem) {
        guard let directory = targetDirectory() else { return }
        let script = "tell application \"Terminal\" to do script \"cd " + shellEscaped(directory.path) + "\""
        NSAppleScript(source: script)?.executeAndReturnError(nil)
    }

    private func targetDirectory() -> URL? {
        if let targeted = FIFinderSyncController.default().targetedURL() {
            return folderURL(for: targeted)
        }

        if let selected = FIFinderSyncController.default().selectedItemURLs()?.first {
            return folderURL(for: selected)
        }

        return nil
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
        alert.informativeText = error.localizedDescription
        alert.alertStyle = .warning
        alert.runModal()
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
        switch self {
        case .text(let text):
            try text.write(to: url, atomically: true, encoding: .utf8)
        case .data(let data):
            try data.write(to: url, options: .atomic)
        }
    }
}
