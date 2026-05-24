import AppKit
import FinderSync
import SwiftUI

@main
struct MacCreateFileApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate

    var body: some Scene {
        WindowGroup(appWindowTitle) {
            ContentView()
                .frame(width: 620, height: 420)
        }
        .defaultPosition(.center)
        .windowResizability(.contentSize)
    }

    private var appWindowTitle: String {
        let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
        return "Mac Create File v \(version ?? "unknown")"
    }
}

final class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationWillFinishLaunching(_ notification: Notification) {
        DockVisibility.applySavedPreference()
    }

    func applicationDidFinishLaunching(_ notification: Notification) {
        DockVisibility.applySavedPreference()
        NSApp.activate(ignoringOtherApps: true)
    }
}

struct ContentView: View {
    @State private var isExtensionEnabled = FIFinderSyncController.isExtensionEnabled
    @State private var showInDock = DockVisibility.isShown
    @State private var statusMessage = ""
    @State private var isUpdatingExtension = false

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            Text("app.subtitle")
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)

            VStack(alignment: .leading, spacing: 12) {
                SettingsToggleGroup {
                    SettingsToggleRow(
                        isOn: Binding(
                            get: { isExtensionEnabled },
                            set: { setExtensionEnabled($0) }
                        ),
                        titleKey: "extensionToggle.title",
                        systemImage: "puzzlepiece.extension",
                        isDisabled: isUpdatingExtension
                    )

                    Divider()
                        .padding(.leading, 56)

                    SettingsToggleRow(
                        isOn: Binding(
                            get: { showInDock },
                            set: { setShowInDock($0) }
                        ),
                        titleKey: "dockToggle.title",
                        systemImage: "dock.rectangle",
                        isDisabled: false
                    )
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
        .padding(.horizontal, 28)
        .padding(.top, 56)
        .padding(.bottom, 28)
        .background(WindowTitleSetter(title: windowTitle))
        .onAppear {
            refreshExtensionStatus()
            showInDock = DockVisibility.isShown
            DockVisibility.applySavedPreference()
        }
    }

    private var windowTitle: String {
        let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
        return "Mac Create File v \(version ?? "unknown")"
    }

    private func refreshExtensionStatus() {
        isExtensionEnabled = FIFinderSyncController.isExtensionEnabled
        statusMessage = isExtensionEnabled
            ? String(localized: "status.extensionAlreadyEnabled")
            : String(localized: "status.extensionAlreadyDisabled")
    }

    private func setExtensionEnabled(_ enabled: Bool) {
        isUpdatingExtension = true

        if enabled {
            enableExtension()
        } else {
            disableExtension()
        }

        isExtensionEnabled = FIFinderSyncController.isExtensionEnabled
        isUpdatingExtension = false
    }

    private func setShowInDock(_ shown: Bool) {
        showInDock = shown
        DockVisibility.setShown(shown)
        statusMessage = shown
            ? String(localized: "status.dockShown")
            : String(localized: "status.dockHidden")
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
            isExtensionEnabled = true
            statusMessage = String(localized: "status.extensionEnabled")
        } else {
            openExtensionSettings()
            isExtensionEnabled = false
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
        isExtensionEnabled = false
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

struct WindowTitleSetter: NSViewRepresentable {
    let title: String

    func makeNSView(context: Context) -> NSView {
        WindowTitleView(title: title)
    }

    func updateNSView(_ nsView: NSView, context: Context) {
        if let titleView = nsView as? WindowTitleView {
            titleView.title = title
        }
    }
}

final class WindowTitleView: NSView {
    var title: String {
        didSet {
            applyTitle()
        }
    }

    init(title: String) {
        self.title = title
        super.init(frame: .zero)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }

    override func viewDidMoveToWindow() {
        super.viewDidMoveToWindow()
        applyTitle()
    }

    private func applyTitle() {
        window?.title = title
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
        .buttonStyle(.bordered)
        .controlSize(.large)
    }
}

struct SettingsToggleGroup<Content: View>: View {
    @ViewBuilder let content: Content

    var body: some View {
        VStack(spacing: 0) {
            content
        }
        .background(Color(nsColor: .controlBackgroundColor), in: RoundedRectangle(cornerRadius: 8))
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color(nsColor: .separatorColor), lineWidth: 0.5)
        )
    }
}

struct SettingsToggleRow: View {
    @Binding var isOn: Bool
    let titleKey: LocalizedStringKey
    let systemImage: String
    let isDisabled: Bool

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: systemImage)
                .font(.title3)
                .foregroundStyle(.secondary)
                .frame(width: 28)

            Text(titleKey)
                .font(.body.weight(.medium))

            Spacer()

            Toggle("", isOn: $isOn)
                .labelsHidden()
                .toggleStyle(.switch)
                .disabled(isDisabled)
        }
        .padding(.horizontal, 14)
        .frame(minHeight: 44)
    }
}

enum DockVisibility {
    private static let key = "showInDock"

    static var isShown: Bool {
        if UserDefaults.standard.object(forKey: key) == nil {
            return true
        }
        return UserDefaults.standard.bool(forKey: key)
    }

    static func setShown(_ shown: Bool) {
        UserDefaults.standard.set(shown, forKey: key)
        apply(shown)
    }

    static func applySavedPreference() {
        let shown = isShown
        apply(shown)
        DispatchQueue.main.async {
            apply(shown)
        }
    }

    static func apply(_ shown: Bool) {
        NSApp.setActivationPolicy(shown ? .regular : .accessory)
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
