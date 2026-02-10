import Foundation

final class LaunchAtLogin {
    private let plistPath: URL
    private let bundleIdentifier = "com.usage"

    init() {
        self.plistPath = FileManager.default.homeDirectoryForCurrentUser
            .appendingPathComponent("Library/LaunchAgents/com.usage.plist")
    }

    var isEnabled: Bool {
        return FileManager.default.fileExists(atPath: plistPath.path)
    }

    func enable() {
        guard let executablePath = Bundle.main.executablePath else { return }

        // Resolve to the app bundle executable if we're inside a .app
        let appPath: String
        if let range = executablePath.range(of: ".app/") {
            appPath = String(executablePath[...range.lowerBound]) + "app"
        } else {
            appPath = executablePath
        }

        var programArgs: [String]
        if appPath.hasSuffix(".app") {
            programArgs = ["/usr/bin/open", appPath]
        } else {
            programArgs = [executablePath]
        }

        let plistContent: [String: Any] = [
            "Label": bundleIdentifier,
            "ProgramArguments": programArgs,
            "RunAtLoad": true,
            "KeepAlive": false,
        ]

        // Ensure LaunchAgents directory exists
        let launchAgentsDir = plistPath.deletingLastPathComponent()
        try? FileManager.default.createDirectory(at: launchAgentsDir, withIntermediateDirectories: true)

        let data = try? PropertyListSerialization.data(
            fromPropertyList: plistContent,
            format: .xml,
            options: 0
        )
        try? data?.write(to: plistPath, options: .atomic)
    }

    func disable() {
        try? FileManager.default.removeItem(at: plistPath)
    }

    func toggle() {
        if isEnabled {
            disable()
        } else {
            enable()
        }
    }
}
