import XCTest
@testable import ZONES

final class CityTests: XCTestCase {
    func testCityDisplayNameUsesNicknameWhenSet() {
        let city = City(
            id: UUID(),
            name: "New York",
            country: "United States",
            timezoneIdentifier: "America/New_York",
            sortOrder: 0,
            isLocal: false,
            isFavorite: false,
            nickname: "NYC",
            colorHex: nil
        )
        
        XCTAssertEqual(city.displayName, "NYC")
    }
    
    func testCityDisplayNameUsesNameWhenNoNickname() {
        let city = City(
            id: UUID(),
            name: "New York",
            country: "United States",
            timezoneIdentifier: "America/New_York",
            sortOrder: 0,
            isLocal: false,
            isFavorite: false,
            nickname: nil,
            colorHex: nil
        )
        
        XCTAssertEqual(city.displayName, "New York")
    }
    
    func testCityTimezoneIsValid() {
        let city = City(
            id: UUID(),
            name: "London",
            country: "United Kingdom",
            timezoneIdentifier: "Europe/London",
            sortOrder: 0,
            isLocal: false,
            isFavorite: false
        )
        
        XCTAssertNotNil(city.timezone)
        XCTAssertEqual(city.timezone?.identifier, "Europe/London")
    }
    
    func testCityFlagEmojiIsNotEmpty() {
        let city = City(
            id: UUID(),
            name: "Tokyo",
            country: "Japan",
            timezoneIdentifier: "Asia/Tokyo",
            sortOrder: 0,
            isLocal: false,
            isFavorite: false
        )
        
        XCTAssertFalse(city.flagEmoji.isEmpty)
    }
    
    func testCityTimezoneAbbreviation() {
        let city = City(
            id: UUID(),
            name: "New York",
            country: "United States",
            timezoneIdentifier: "America/New_York",
            sortOrder: 0,
            isLocal: false,
            isFavorite: false
        )
        
        XCTAssertFalse(city.timezoneAbbreviation.isEmpty)
    }
}
