import XCTest
@testable import ZONES

final class CoordinateServiceTests: XCTestCase {
    var service: CoordinateService!
    
    override func setUp() {
        super.setUp()
        service = CoordinateService.shared
    }
    
    func testCoordinateForKnownTimezone() {
        let coord = service.coordinate(for: "America/New_York")
        
        XCTAssertNotNil(coord)
        XCTAssertEqual(coord?.lat, 40.0, accuracy: 1.0)
        XCTAssertEqual(coord?.lon, -74.0, accuracy: 1.0)
    }
    
    func testCoordinateForLondon() {
        let coord = service.coordinate(for: "Europe/London")
        
        XCTAssertNotNil(coord)
        XCTAssertEqual(coord?.lat, 51.0, accuracy: 1.0)
        XCTAssertEqual(coord?.lon, 0.0, accuracy: 1.0)
    }
    
    func testCoordinateForTokyo() {
        let coord = service.coordinate(for: "Asia/Tokyo")
        
        XCTAssertNotNil(coord)
        XCTAssertEqual(coord?.lat, 35.0, accuracy: 1.0)
        XCTAssertEqual(coord?.lon, 139.0, accuracy: 1.0)
    }
    
    func testCoordinate2DReturnsValidCLLocationCoordinate2D() {
        let coord2D = service.coordinate2D(for: "America/Los_Angeles")
        
        XCTAssertEqual(coord2D.latitude, 34.0, accuracy: 1.0)
        XCTAssertEqual(coord2D.longitude, -118.0, accuracy: 1.0)
    }
    
    func testCoordinateFallbackForUnknownTimezone() {
        let coord = service.coordinate(for: "Unknown/Timezone")
        
        XCTAssertNotNil(coord)
    }
}
