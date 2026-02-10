import AppKit

final class AppDelegate: NSObject, NSApplicationDelegate {
    private var csvStore: CSVStore!
    private var locationManager: LocationManager!
    private var usageTracker: UsageTracker!
    private var statusBarManager: StatusBarManager!
    private var launchAtLogin: LaunchAtLogin!

    func applicationDidFinishLaunching(_ notification: Notification) {
        csvStore = CSVStore()
        locationManager = LocationManager()
        launchAtLogin = LaunchAtLogin()

        usageTracker = UsageTracker(store: csvStore, locationManager: locationManager)
        statusBarManager = StatusBarManager(
            locationManager: locationManager,
            launchAtLogin: launchAtLogin,
            csvStore: csvStore
        )

        statusBarManager.setup()
        locationManager.start()
        usageTracker.start()
    }

    func applicationWillTerminate(_ notification: Notification) {
        usageTracker.stop()
        locationManager.stop()
    }
}
