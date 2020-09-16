import XCTest
@testable import MVVM_TDD_WeatherApp


class WeatherTest: XCTestCase{
    
    func testWeatherHaveMaxTemperatureAndDescription() {
        let weather = Weather(currentTemp: 12.9, desc: "blue Sky")
        XCTAssertEqual(Weather(), weather)
    }
    
}
