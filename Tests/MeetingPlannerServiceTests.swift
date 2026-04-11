import XCTest
@testable import ZONES

final class MeetingPlannerServiceTests: XCTestCase {
    var service: MeetingPlannerService!
    
    override func setUp() {
        super.setUp()
        service = MeetingPlannerService()
    }
    
    func testCalculateSlotsReturnsNonEmptyArray() {
        let cities = [
            City(id: UUID(), name: "New York", country: "US", timezoneIdentifier: "America/New_York", sortOrder: 0, isLocal: false, isFavorite: false),
            City(id: UUID(), name: "London", country: "UK", timezoneIdentifier: "Europe/London", sortOrder: 1, isLocal: false, isFavorite: false)
        ]
        let workingHours = WorkingHours.default
        
        let slots = service.calculateSlots(
            duration: 3600,
            participants: cities,
            workingHours: workingHours,
            onDate: Date()
        )
        
        XCTAssertFalse(slots.isEmpty)
    }
    
    func testCalculateSlotsWithNoParticipants() {
        let workingHours = WorkingHours.default
        
        let slots = service.calculateSlots(
            duration: 3600,
            participants: [],
            workingHours: workingHours,
            onDate: Date()
        )
        
        XCTAssertTrue(slots.isEmpty)
    }
    
    func testFormatSlotReturnsNonEmptyString() {
        let slot = MeetingSlot(startTimeUTC: Date(), duration: 3600, conflicts: [])
        let cities = [
            City(id: UUID(), name: "New York", country: "US", timezoneIdentifier: "America/New_York", sortOrder: 0, isLocal: false, isFavorite: false)
        ]
        
        let result = service.formatSlot(slot, participants: cities, inZone: .current)
        
        XCTAssertFalse(result.isEmpty)
        XCTAssertTrue(result.contains("New York"))
    }
}
