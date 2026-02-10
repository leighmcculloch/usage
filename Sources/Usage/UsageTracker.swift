import AppKit
import Foundation

final class UsageTracker {
    private let store: CSVStore
    private let locationManager: LocationManager
    private var isActive = false
    private var hourTimer: Timer?
    private var sessionStartHour: Date?

    init(store: CSVStore, locationManager: LocationManager) {
        self.store = store
        self.locationManager = locationManager
    }

    func start() {
        subscribeToNotifications()
        scheduleHourTimer()

        locationManager.onLocationUpdated = { [weak self] in
            self?.locationDidUpdate()
        }

        markActive()
    }

    func stop() {
        markInactive()
        hourTimer?.invalidate()
        hourTimer = nil
    }

    private func subscribeToNotifications() {
        let ws = NSWorkspace.shared.notificationCenter
        let dn = DistributedNotificationCenter.default()

        ws.addObserver(self, selector: #selector(handleWake), name: NSWorkspace.screensDidWakeNotification, object: nil)
        ws.addObserver(self, selector: #selector(handleSleep), name: NSWorkspace.screensDidSleepNotification, object: nil)
        ws.addObserver(self, selector: #selector(handleActive), name: NSWorkspace.sessionDidBecomeActiveNotification, object: nil)
        ws.addObserver(self, selector: #selector(handleInactive), name: NSWorkspace.sessionDidResignActiveNotification, object: nil)

        dn.addObserver(self, selector: #selector(handleScreenLocked), name: NSNotification.Name("com.apple.screenIsLocked"), object: nil)
        dn.addObserver(self, selector: #selector(handleScreenUnlocked), name: NSNotification.Name("com.apple.screenIsUnlocked"), object: nil)
    }

    @objc private func handleWake() { markActive() }
    @objc private func handleActive() { markActive() }
    @objc private func handleScreenUnlocked() { markActive() }

    @objc private func handleSleep() { markInactive() }
    @objc private func handleInactive() { markInactive() }
    @objc private func handleScreenLocked() { markInactive() }

    private func markActive() {
        isActive = true
        recordCurrentHourIfNeeded()
    }

    private func markInactive() {
        isActive = false
        sessionStartHour = nil
    }

    private func recordCurrentHourIfNeeded() {
        guard isActive else { return }
        let now = Date()
        let hour = UsageRecord.floorToHour(now)

        if sessionStartHour == nil {
            sessionStartHour = hour
        }

        store.recordHour(
            hour: hour,
            suburb: locationManager.suburb,
            state: locationManager.state,
            country: locationManager.country
        )
    }

    private func locationDidUpdate() {
        guard let since = sessionStartHour else { return }
        let suburb = locationManager.suburb
        let state = locationManager.state
        let country = locationManager.country
        guard !suburb.isEmpty || !state.isEmpty || !country.isEmpty else { return }

        store.updateLocationForCurrentSession(
            suburb: suburb,
            state: state,
            country: country,
            since: since
        )
    }

    private func scheduleHourTimer() {
        // Fire at the next hour boundary, then every hour
        let now = Date()
        let nextHour = UsageRecord.ceilToHour(now.addingTimeInterval(1))
        let delay = nextHour.timeIntervalSince(now)

        hourTimer?.invalidate()
        hourTimer = Timer.scheduledTimer(withTimeInterval: delay, repeats: false) { [weak self] _ in
            self?.hourBoundaryFired()
            // Now schedule repeating timer every hour
            self?.hourTimer = Timer.scheduledTimer(withTimeInterval: 3600, repeats: true) { [weak self] _ in
                self?.hourBoundaryFired()
            }
        }
    }

    private func hourBoundaryFired() {
        recordCurrentHourIfNeeded()
    }
}
