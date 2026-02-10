import CoreLocation
import Foundation

final class LocationManager: NSObject, CLLocationManagerDelegate {
    private let manager = CLLocationManager()
    private let geocoder = CLGeocoder()

    private(set) var suburb: String = ""
    private(set) var state: String = ""
    private(set) var country: String = ""

    var onLocationUpdated: (() -> Void)?

    private var lastGeocodedLocation: CLLocation?

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        manager.distanceFilter = 500
    }

    func start() {
        manager.requestWhenInUseAuthorization()
        manager.startMonitoringSignificantLocationChanges()
        // Also start standard updates as fallback
        manager.startUpdatingLocation()
    }

    func stop() {
        manager.stopMonitoringSignificantLocationChanges()
        manager.stopUpdatingLocation()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }

        // Only re-geocode if moved significantly
        if let last = lastGeocodedLocation,
           location.distance(from: last) < 500 {
            return
        }

        lastGeocodedLocation = location
        geocoder.cancelGeocode()
        geocoder.reverseGeocodeLocation(location) { [weak self] placemarks, _ in
            guard let self = self, let placemark = placemarks?.first else { return }
            let newSuburb = placemark.locality ?? ""
            let newState = placemark.administrativeArea ?? ""
            let newCountry = placemark.country ?? ""
            let changed = newSuburb != self.suburb || newState != self.state || newCountry != self.country
            self.suburb = newSuburb
            self.state = newState
            self.country = newCountry
            if changed {
                self.onLocationUpdated?()
            }
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        // Location unavailable — fields stay as-is (possibly blank)
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedAlways, .authorized:
            manager.startUpdatingLocation()
        default:
            break
        }
    }
}
