import AppKit

final class StatusBarManager: NSObject {
    private var statusItem: NSStatusItem?
    private let locationManager: LocationManager
    private let launchAtLogin: LaunchAtLogin
    private let csvStore: CSVStore
    private var statusMenuItem: NSMenuItem?

    init(locationManager: LocationManager, launchAtLogin: LaunchAtLogin, csvStore: CSVStore) {
        self.locationManager = locationManager
        self.launchAtLogin = launchAtLogin
        self.csvStore = csvStore
    }

    func setup() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

        if let button = statusItem?.button {
            button.image = NSImage(systemSymbolName: "clock", accessibilityDescription: "Usage")
        }

        buildMenu()

        // Periodically update the status line
        Timer.scheduledTimer(withTimeInterval: 30, repeats: true) { [weak self] _ in
            self?.updateStatusLine()
        }
    }

    private func buildMenu() {
        let menu = NSMenu()

        statusMenuItem = NSMenuItem(title: "Tracking", action: nil, keyEquivalent: "")
        statusMenuItem?.isEnabled = false
        menu.addItem(statusMenuItem!)
        updateStatusLine()

        menu.addItem(NSMenuItem.separator())

        let openFolder = NSMenuItem(title: "Open Data Folder", action: #selector(openDataFolder), keyEquivalent: "")
        openFolder.target = self
        menu.addItem(openFolder)

        let launchItem = NSMenuItem(title: "Launch at Login", action: #selector(toggleLaunchAtLogin), keyEquivalent: "")
        launchItem.target = self
        launchItem.state = launchAtLogin.isEnabled ? .on : .off
        menu.addItem(launchItem)

        menu.addItem(NSMenuItem.separator())

        let quit = NSMenuItem(title: "Quit", action: #selector(quitApp), keyEquivalent: "q")
        quit.target = self
        menu.addItem(quit)

        statusItem?.menu = menu
    }

    private func updateStatusLine() {
        let suburb = locationManager.suburb
        let state = locationManager.state
        if !suburb.isEmpty {
            var location = suburb
            if !state.isEmpty { location += ", \(state)" }
            statusMenuItem?.title = "Tracking: \(location)"
        } else {
            statusMenuItem?.title = "Tracking"
        }
    }

    @objc private func openDataFolder() {
        NSWorkspace.shared.open(csvStore.directory)
    }

    @objc private func toggleLaunchAtLogin(_ sender: NSMenuItem) {
        launchAtLogin.toggle()
        sender.state = launchAtLogin.isEnabled ? .on : .off
    }

    @objc private func quitApp() {
        NSApplication.shared.terminate(nil)
    }
}
