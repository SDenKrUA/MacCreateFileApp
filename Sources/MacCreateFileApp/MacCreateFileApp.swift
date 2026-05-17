import AppKit
import SwiftUI

@main
struct MacCreateFileApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate

    var body: some Scene {
        WindowGroup {
            ContentView()
                .frame(width: 620, height: 680)
        }
        .windowResizability(.contentSize)
    }
}

final class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.regular)
        NSApp.activate(ignoringOtherApps: true)
    }
}

struct ContentView: View {
    @State private var statusMessage = String(localized: "status.ready")
    @State private var allowedFolders = AllowedFolderStore.load()

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            VStack(alignment: .leading, spacing: 8) {
                Text("app.title")
                    .font(.system(size: 30, weight: .semibold))
                Text("app.subtitle")
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            VStack(alignment: .leading, spacing: 12) {
                ActionButton(title: String(localized: "button.enableExtension"), systemImage: "puzzlepiece.extension") {
                    enableExtension()
                }
                ActionButton(title: String(localized: "button.disableExtension"), systemImage: "puzzlepiece.extension.fill") {
                    disableExtension()
                }
                ActionButton(title: String(localized: "button.openSettings"), systemImage: "gearshape") {
                    openExtensionSettings()
                }
                ActionButton(title: String(localized: "button.restartFinder"), systemImage: "arrow.clockwise") {
                    restartFinder()
                }
                ActionButton(title: String(localized: "button.uninstall"), systemImage: "trash") {
                    confirmUninstall()
                }
            }

            Divider()

            VStack(alignment: .leading, spacing: 10) {
                Text("allowed.title")
                    .font(.headline)
                Text("allowed.subtitle")
                    .font(.callout)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)

                if allowedFolders.isEmpty {
                    Text("allowed.empty")
                        .font(.callout)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, minHeight: 72, alignment: .center)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(.quaternary)
                        )
                } else {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 8) {
                            ForEach(allowedFolders) { folder in
                                HStack(spacing: 10) {
                                    Image(systemName: "folder")
                                        .foregroundStyle(.secondary)
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(folder.name)
                                            .font(.callout.weight(.medium))
                                        Text(folder.path)
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                            .lineLimit(1)
                                            .truncationMode(.middle)
                                    }
                                    Spacer()
                                    Button {
                                        removeAllowedFolder(folder)
                                    } label: {
                                        Image(systemName: "xmark.circle")
                                    }
                                    .buttonStyle(.plain)
                                    .help(String(localized: "allowed.remove"))
                                }
                                .padding(.vertical, 4)
                            }
                        }
                        .padding(10)
                    }
                    .frame(height: 118)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(.quaternary)
                    )
                }

                HStack(spacing: 8) {
                    Button {
                        addAllowedFolderWithPanel()
                    } label: {
                        Label(String(localized: "allowed.addFolder"), systemImage: "folder.badge.plus")
                    }
                    Button {
                        addKnownFolder(.documents)
                    } label: {
                        Label(String(localized: "allowed.addDocuments"), systemImage: "doc.text")
                    }
                    Button {
                        addKnownFolder(.desktop)
                    } label: {
                        Label(String(localized: "allowed.addDesktop"), systemImage: "desktopcomputer")
                    }
                }

                HStack(spacing: 8) {
                    Button {
                        addKnownFolder(.iCloudDrive)
                    } label: {
                        Label(String(localized: "allowed.addICloud"), systemImage: "icloud")
                    }
                    Button {
                        addKnownFolder(.cloudStorage)
                    } label: {
                        Label(String(localized: "allowed.addCloudStorage"), systemImage: "externaldrive")
                    }
                }
            }

            Divider()

            Text(statusMessage)
                .font(.callout)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)

            Spacer()
        }
        .padding(28)
    }

    private func addAllowedFolderWithPanel() {
        openAllowedFolderPanel(initialURL: nil)
    }

    private func openAllowedFolderPanel(initialURL: URL?) {
        let panel = NSOpenPanel()
        panel.canChooseFiles = false
        panel.canChooseDirectories = true
        panel.allowsMultipleSelection = true
        panel.canCreateDirectories = false
        panel.directoryURL = initialURL
        panel.prompt = String(localized: "allowed.panelPrompt")
        panel.message = String(localized: "allowed.panelMessage")

        guard panel.runModal() == .OK else {
            return
        }

        addAllowedFolders(panel.urls)
    }

    private func addKnownFolder(_ folder: KnownFolder) {
        guard let url = folder.url else {
            statusMessage = String(format: String(localized: "allowed.folderMissing"), folder.localizedName)
            return
        }

        openAllowedFolderPanel(initialURL: url)
    }

    private func addAllowedFolders(_ urls: [URL]) {
        do {
            allowedFolders = try AllowedFolderStore.add(urls: urls)
            restartFinderAfterAllowedFolderChange()
            statusMessage = String(localized: "allowed.saved")
        } catch {
            statusMessage = String(format: String(localized: "allowed.saveFailed"), error.localizedDescription)
        }
    }

    private func removeAllowedFolder(_ folder: AllowedFolderRecord) {
        do {
            allowedFolders = try AllowedFolderStore.remove(id: folder.id)
            restartFinderAfterAllowedFolderChange()
            statusMessage = String(localized: "allowed.removed")
        } catch {
            statusMessage = String(format: String(localized: "allowed.saveFailed"), error.localizedDescription)
        }
    }

    private func restartFinderAfterAllowedFolderChange() {
        let enableResult = Shell.run("/usr/bin/pluginkit", arguments: [
            "-e", "use",
            "-i", AllowedFolderStore.extensionID
        ])

        if !enableResult.isSuccess {
            statusMessage = String(format: String(localized: "status.commandFailed"), enableResult.output)
        }

        _ = Shell.run("/usr/bin/killall", arguments: ["Finder"])
    }

    private func enableExtension() {
        guard let extensionURL = Bundle.main.builtInPlugInsURL?
            .appendingPathComponent("MacCreateFileFinderExtension.appex") else {
            statusMessage = String(localized: "status.extensionMissing")
            return
        }

        let registerResult = Shell.run("/usr/bin/pluginkit", arguments: [
            "-a", extensionURL.path
        ])

        guard registerResult.isSuccess else {
            statusMessage = String(format: String(localized: "status.commandFailed"), registerResult.output)
            return
        }

        let enableResult = Shell.run("/usr/bin/pluginkit", arguments: [
            "-e", "use",
            "-i", "com.sdenkrua.MacCreateFileApp.FinderExtension"
        ])

        guard enableResult.isSuccess else {
            statusMessage = String(format: String(localized: "status.commandFailed"), enableResult.output)
            return
        }

        _ = Shell.run("/usr/bin/killall", arguments: ["Finder"])

        statusMessage = String(localized: "status.extensionEnabled")
    }

    private func disableExtension() {
        let disableResult = Shell.run("/usr/bin/pluginkit", arguments: [
            "-e", "ignore",
            "-i", "com.sdenkrua.MacCreateFileApp.FinderExtension"
        ])

        guard disableResult.isSuccess else {
            statusMessage = String(format: String(localized: "status.commandFailed"), disableResult.output)
            return
        }

        _ = Shell.run("/usr/bin/killall", arguments: ["Finder"])
        statusMessage = String(localized: "status.extensionDisabled")
    }

    private func openExtensionSettings() {
        let modernURL = URL(string: "x-apple.systempreferences:com.apple.ExtensionsPreferences")!
        NSWorkspace.shared.open(modernURL)
        statusMessage = String(localized: "status.openedSettings")
    }

    private func restartFinder() {
        let result = Shell.run("/usr/bin/killall", arguments: ["Finder"])
        statusMessage = result.isSuccess
            ? String(localized: "status.finderRestarted")
            : String(format: String(localized: "status.commandFailed"), result.output)
    }

    private func confirmUninstall() {
        let alert = NSAlert()
        alert.messageText = String(localized: "uninstall.confirmTitle")
        alert.informativeText = String(localized: "uninstall.confirmMessage")
        alert.alertStyle = .warning
        alert.addButton(withTitle: String(localized: "uninstall.confirmButton"))
        alert.addButton(withTitle: String(localized: "uninstall.cancelButton"))

        guard alert.runModal() == .alertFirstButtonReturn else {
            statusMessage = String(localized: "status.uninstallCancelled")
            return
        }

        uninstallCompletely()
    }

    private func uninstallCompletely() {
        let extensionID = "com.sdenkrua.MacCreateFileApp.FinderExtension"
        let appGroupID = "group.com.sdenkrua.MacCreateFileApp"
        var failures: [String] = []

        let commands: [(String, [String], Bool)] = [
            ("/usr/bin/pluginkit", ["-e", "ignore", "-i", extensionID], true),
            ("/usr/bin/killall", ["Finder"], true),
            ("/bin/rm", ["-rf", NSHomeDirectory() + "/Library/Application Scripts/" + extensionID], true),
            ("/bin/rm", ["-f", NSHomeDirectory() + "/Library/Logs/MacCreateFileApp.log"], true),
            ("/bin/rm", ["-rf", NSHomeDirectory() + "/Library/Application Support/MacCreateFileApp"], true),
            ("/bin/rm", ["-rf", NSHomeDirectory() + "/Library/Group Containers/" + appGroupID], true),
            ("/bin/rm", ["-f", NSHomeDirectory() + "/Library/Preferences/" + appGroupID + ".plist"], true),
            ("/bin/rm", ["-rf", NSHomeDirectory() + "/Library/Containers/" + extensionID], true),
            ("/usr/bin/killall", ["cfprefsd"], true)
        ]

        for (executable, arguments, allowFailure) in commands {
            let result = Shell.run(executable, arguments: arguments)
            if !result.isSuccess && !allowFailure {
                let command = ([executable] + arguments).joined(separator: " ")
                failures.append("\(command): \(result.output)")
            }
        }

        if failures.isEmpty {
            statusMessage = String(localized: "status.uninstallReady")
        } else {
            statusMessage = String(format: String(localized: "status.uninstallPartial"), failures.joined(separator: "\n"))
        }
    }
}

enum KnownFolder {
    case desktop
    case documents
    case iCloudDrive
    case cloudStorage

    var url: URL? {
        let home = URL(fileURLWithPath: NSHomeDirectory(), isDirectory: true)
        switch self {
        case .desktop:
            return existingDirectory(home.appendingPathComponent("Desktop", isDirectory: true))
        case .documents:
            return existingDirectory(home.appendingPathComponent("Documents", isDirectory: true))
        case .iCloudDrive:
            return existingDirectory(home.appendingPathComponent("Library/Mobile Documents/com~apple~CloudDocs", isDirectory: true))
        case .cloudStorage:
            return existingDirectory(home.appendingPathComponent("Library/CloudStorage", isDirectory: true))
        }
    }

    var localizedName: String {
        switch self {
        case .desktop:
            return String(localized: "allowed.addDesktop")
        case .documents:
            return String(localized: "allowed.addDocuments")
        case .iCloudDrive:
            return String(localized: "allowed.addICloud")
        case .cloudStorage:
            return String(localized: "allowed.addCloudStorage")
        }
    }

    private func existingDirectory(_ url: URL) -> URL? {
        var isDirectory: ObjCBool = false
        guard FileManager.default.fileExists(atPath: url.path, isDirectory: &isDirectory), isDirectory.boolValue else {
            return nil
        }
        return url
    }
}

struct AllowedFolderRecord: Identifiable, Equatable {
    let id: String
    let name: String
    let path: String
    let bookmarkData: Data
}

enum AllowedFolderStore {
    static let extensionID = "com.sdenkrua.MacCreateFileApp.FinderExtension"

    static var storeURL: URL {
        URL(fileURLWithPath: NSHomeDirectory(), isDirectory: true)
            .appendingPathComponent("Library/Containers/\(extensionID)/Data/Library/Application Support/MacCreateFileApp/AllowedFolders.plist")
    }

    static func load() -> [AllowedFolderRecord] {
        guard let items = NSArray(contentsOf: storeURL) as? [[String: Any]] else {
            return []
        }

        return items.compactMap { item in
            guard let id = item["id"] as? String,
                  let name = item["name"] as? String,
                  let path = item["path"] as? String,
                  let bookmarkData = item["bookmarkData"] as? Data else {
                return nil
            }

            return AllowedFolderRecord(id: id, name: name, path: path, bookmarkData: bookmarkData)
        }
    }

    static func add(urls: [URL]) throws -> [AllowedFolderRecord] {
        var records = load()

        for url in urls {
            let standardizedURL = url.standardizedFileURL
            let bookmarkData = try standardizedURL.bookmarkData(
                options: [.withSecurityScope],
                includingResourceValuesForKeys: nil,
                relativeTo: nil
            )
            let path = standardizedURL.path
            let record = AllowedFolderRecord(
                id: path,
                name: standardizedURL.lastPathComponent.isEmpty ? path : standardizedURL.lastPathComponent,
                path: path,
                bookmarkData: bookmarkData
            )

            records.removeAll { $0.path == path }
            records.append(record)
        }

        records.sort { $0.path.localizedStandardCompare($1.path) == .orderedAscending }
        try save(records)
        return records
    }

    static func remove(id: String) throws -> [AllowedFolderRecord] {
        let records = load().filter { $0.id != id }
        try save(records)
        return records
    }

    private static func save(_ records: [AllowedFolderRecord]) throws {
        try FileManager.default.createDirectory(
            at: storeURL.deletingLastPathComponent(),
            withIntermediateDirectories: true
        )

        let items = records.map { record in
            [
                "id": record.id,
                "name": record.name,
                "path": record.path,
                "bookmarkData": record.bookmarkData
            ] as [String: Any]
        }

        guard (items as NSArray).write(to: storeURL, atomically: true) else {
            throw NSError(domain: "AllowedFolderStore", code: 1, userInfo: [
                NSLocalizedDescriptionKey: "Could not save allowed folders."
            ])
        }
    }
}

struct ActionButton: View {
    let title: String
    let systemImage: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Label(title, systemImage: systemImage)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .buttonStyle(.borderedProminent)
        .controlSize(.large)
    }
}

enum Shell {
    struct Result {
        let terminationStatus: Int32
        let output: String

        var isSuccess: Bool { terminationStatus == 0 }
    }

    static func run(_ executable: String, arguments: [String]) -> Result {
        let process = Process()
        let pipe = Pipe()
        process.executableURL = URL(fileURLWithPath: executable)
        process.arguments = arguments
        process.standardOutput = pipe
        process.standardError = pipe

        do {
            try process.run()
            process.waitUntilExit()
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            let output = String(data: data, encoding: .utf8) ?? ""
            return Result(terminationStatus: process.terminationStatus, output: output.trimmingCharacters(in: .whitespacesAndNewlines))
        } catch {
            return Result(terminationStatus: 1, output: error.localizedDescription)
        }
    }
}
