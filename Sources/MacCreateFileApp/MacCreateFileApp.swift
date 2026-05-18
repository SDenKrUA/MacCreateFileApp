import AppKit
import FinderSync
import SwiftUI

@main
struct MacCreateFileApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate

    var body: some Scene {
        WindowGroup {
            ContentView()
                .frame(width: 620, height: 420)
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

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            VStack(alignment: .leading, spacing: 8) {
                Text("app.title")
                    .font(.system(size: 30, weight: .semibold))
                Text(appDisplayVersion)
                    .font(.headline)
                    .foregroundStyle(.secondary)
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

            Text("app.toolbarHint")
                .font(.callout)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)

            Text(statusMessage)
                .font(.callout)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)

            Spacer()
        }
        .padding(28)
    }

    private var appDisplayVersion: String {
        let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
        return String(format: String(localized: "app.version"), version ?? "unknown")
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

        if FIFinderSyncController.isExtensionEnabled {
            statusMessage = String(localized: "status.extensionEnabled")
        } else {
            openExtensionSettings()
            statusMessage = String(localized: "status.extensionEnabledNeedsSettings")
        }
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
