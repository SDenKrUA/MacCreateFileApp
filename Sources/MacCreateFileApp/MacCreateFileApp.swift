import AppKit
import SwiftUI

@main
struct MacCreateFileApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate

    var body: some Scene {
        WindowGroup {
            ContentView()
                .frame(width: 520, height: 380)
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
        VStack(alignment: .leading, spacing: 22) {
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
                ActionButton(title: String(localized: "button.openSettings"), systemImage: "gearshape") {
                    openExtensionSettings()
                }
                ActionButton(title: String(localized: "button.restartFinder"), systemImage: "arrow.clockwise") {
                    restartFinder()
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
