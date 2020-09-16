import XCTest
import CoreLocation
@testable import MVVM_TDD_WeatherApp

class CoreLocationTests: XCTestCase {
    
    
    struct MockLocationFetcher: LocationFetcher {
        var desiredAccuracy: CLLocationAccuracy = kCLLocationAccuracyBestForNavigation
        
        var activityType: CLActivityType = .fitness
        weak var locationFetcherDelegate: LocationFetcherDelegate?
        
        // callback to provide mock locations
        var handleRequestLocation: (() -> CLLocation)?
        
        func startUpdatingLocation() {
            guard let location = handleRequestLocation?() else { return }
            locationFetcherDelegate?.locationFetcher(self, didUpdateLocations: [location])
        }
        
        func stopUpdatingLocation() {
            //
        }
        
        func requestWhenInUseAuthorization() {
            //
        }
        
        func requestAlwaysAuthorization() {
            //
        }
        
        func islocationServicesEnabled() -> Bool {
            return true
        }
    }
    
    
    func testStartForOneLocation() {
        var locationFetcher = MockLocationFetcher()
        let requestLocationExpectation = expectation(description: "request location")
        
        locationFetcher.handleRequestLocation = {
            requestLocationExpectation.fulfill()
            return CLLocation(latitude: 37.3293, longitude: -121.8893)
        }
        let locationProvider = LocationProvider(locationFetcher: locationFetcher)
    XCTAssertNotEqual(locationProvider.locationFetcher.desiredAccuracy, 0)
    XCTAssertNotNil(locationProvider.locationFetcher.locationFetcherDelegate)
        
        let completionExpectation = expectation(description: "completion")
        locationProvider.getLastLocation = { loc in
            XCTAssertNotNil(loc)
            completionExpectation.fulfill()
        }
        
        locationProvider.startForOneLocation()
        
        wait(for: [requestLocationExpectation, completionExpectation], timeout: 1)

    }
}
