import XCTest
@testable import ZONES

final class WorkingHoursTests: XCTestCase {
    func testWorkingHoursDefaultValues() {
        let hours = WorkingHours.default
        
        XCTAssertEqual(hours.startHour, 9)
        XCTAssertEqual(hours.startMinute, 0)
        XCTAssertEqual(hours.endHour, 18)
        XCTAssertEqual(hours.endMinute, 0)
    }
    
    func testStartMinutesFromMidnight() {
        let hours = WorkingHours(startHour: 9, startMinute: 30, endHour: 18, endMinute: 0)
        
        XCTAssertEqual(hours.startMinutesFromMidnight, 9 * 60 + 30)
    }
    
    func testEndMinutesFromMidnight() {
        let hours = WorkingHours(startHour: 9, startMinute: 0, endHour: 17, endMinute: 30)
        
        XCTAssertEqual(hours.endMinutesFromMidnight, 17 * 60 + 30)
    }
}
