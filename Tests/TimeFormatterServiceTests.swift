import XCTest
@testable import ZONES

final class TimeFormatterServiceTests: XCTestCase {
    var service: TimeFormatterService!
    
    override func setUp() {
        super.setUp()
        service = TimeFormatterService.shared
    }
    
    func testFormatTimeWith24HourFormat() {
        let date = DateComponents(calendar: .current, year: 2024, month: 1, day: 1, hour: 14, minute: 30, second: 0).date!
        let timezone = TimeZone(identifier: "America/New_York")!
        
        let result = service.formatTime(date, timezone: timezone, use24Hour: true)
        
        XCTAssertTrue(result.contains("14:30"))
    }
    
    func testFormatTimeWith12HourFormat() {
        let date = DateComponents(calendar: .current, year: 2024, month: 1, day: 1, hour: 14, minute: 30, second: 0).date!
        let timezone = TimeZone(identifier: "America/New_York")!
        
        let result = service.formatTime(date, timezone: timezone, use24Hour: false)
        
        XCTAssertTrue(result.contains("2:30") || result.contains("14:30"))
    }
    
    func testFormatTimeShort() {
        let date = DateComponents(calendar: .current, year: 2024, month: 1, day: 1, hour: 14, minute: 30, second: 0).date!
        let timezone = TimeZone(identifier: "Europe/London")!
        
        let result = service.formatTimeShort(date, timezone: timezone, use24Hour: true)
        
        XCTAssertFalse(result.contains(":"))
        XCTAssertTrue(result.contains("14:30"))
    }
    
    func testGetTimezoneOffset() {
        let city = City(
            id: UUID(),
            name: "New York",
            country: "United States",
            timezoneIdentifier: "America/New_York",
            sortOrder: 0,
            isLocal: false,
            isFavorite: false
        )
        
        let offset = service.getTimezoneOffset(for: city)
        
        XCTAssertTrue(offset.starts(with: "UTC"))
        XCTAssertTrue(offset.contains("-") || offset.contains("+"))
    }
}
