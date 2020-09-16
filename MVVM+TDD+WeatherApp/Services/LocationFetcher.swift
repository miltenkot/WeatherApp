import Foundation
import CoreLocation

protocol LocationFetcher {
    var locationFetcherDelegate: LocationFetcherDelegate? {get set}
    
    var desiredAccuracy: CLLocationAccuracy {get set}
    var activityType: CLActivityType {get set}
    
    func startUpdatingLocation()
    func stopUpdatingLocation()
    func requestWhenInUseAuthorization()
    func requestAlwaysAuthorization()
    func islocationServicesEnabled() -> Bool
}

protocol LocationFetcherDelegate: class {
    func locationFetcher(_ fetcher: LocationFetcher, didUpdateLocations locations: [CLLocation])
}

extension CLLocationManager: LocationFetcher {
    var locationFetcherDelegate: LocationFetcherDelegate? {
        get {
            return delegate as! LocationFetcherDelegate?
        }
        set {
            delegate = newValue as! CLLocationManagerDelegate?
        }
    }
    
    func islocationServicesEnabled() -> Bool {
        let authorizationStatus = CLLocationManager.authorizationStatus()
        if authorizationStatus != .authorizedWhenInUse && authorizationStatus != .authorizedAlways {
            //alert
            print("Location Services are disabled!!! Status: \(authorizationStatus.rawValue)")
            return false
        }
        
        return CLLocationManager.locationServicesEnabled()
    }
}

class LocationProvider: NSObject {
    
    var locationFetcher: LocationFetcher
    var isTrackinLocationMode: Bool = false
    var getLastLocation: ((CLLocation?) -> Void)?
    
    init(locationFetcher: LocationFetcher = CLLocationManager()) {
        self.locationFetcher = locationFetcher
        self.locationFetcher.activityType = .fitness
        self.locationFetcher.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        
        super.init()
        self.locationFetcher.locationFetcherDelegate = self
        requestAuthorization()
    }
    
    func startForOneLocation() {
        guard locationFetcher.islocationServicesEnabled() else {return}
        isUpdate = false
        locationFetcher.startUpdatingLocation()
    }
    
    func startForTracking() {
        isTrackinLocationMode = true
    }
    
    func requestAuthorization() {
        switch CLLocationManager.authorizationStatus() {
        case .notDetermined:
            locationFetcher.requestWhenInUseAuthorization()
        case .authorizedWhenInUse:
            if isTrackinLocationMode {
                locationFetcher.requestAlwaysAuthorization()
            }
        default:
            break
        }
    }
    
    var isUpdate = false
}

extension LocationProvider: LocationFetcherDelegate {
    func locationFetcher(_ fetcher: LocationFetcher, didUpdateLocations locations: [CLLocation]) {
        if !isTrackinLocationMode && !isUpdate  {
            locationFetcher.stopUpdatingLocation()
            isUpdate = true
            getLastLocation?(locations.last)
        }
    }
}

extension LocationProvider: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        locationFetcher(manager, didUpdateLocations: locations)
    }
}

