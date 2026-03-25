import Foundation

struct City: Identifiable, Codable, Hashable {
    let id: UUID
    var name: String
    var country: String
    var timezoneIdentifier: String
    var sortOrder: Int
    var isLocal: Bool
    var isFavorite: Bool

    init(
        id: UUID = UUID(),
        name: String,
        country: String,
        timezoneIdentifier: String,
        sortOrder: Int = 0,
        isLocal: Bool = false,
        isFavorite: Bool = false
    ) {
        self.id = id
        self.name = name
        self.country = country
        self.timezoneIdentifier = timezoneIdentifier
        self.sortOrder = sortOrder
        self.isLocal = isLocal
        self.isFavorite = isFavorite
    }

    var timezone: TimeZone {
        TimeZone(identifier: timezoneIdentifier) ?? .current
    }

    var flagEmoji: String {
        let base: UInt32 = 127397
        var emoji = ""
        for scalar in country.uppercased().unicodeScalars {
            if let unicode = UnicodeScalar(base + scalar.value) {
                emoji.append(Character(unicode))
            }
        }
        // Return a simple globe emoji if country code lookup fails
        return emoji.count == 2 ? emoji : "🌍"
    }
}

struct CityDataEntry: Identifiable, Codable {
    var id: String { name }
    let name: String
    let country: String
    let timezone: String
    let countryCode: String
}
