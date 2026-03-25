import Foundation

struct City: Identifiable, Codable, Hashable {
    let id: UUID
    var name: String
    var country: String
    var timezoneIdentifier: String
    var sortOrder: Int
    var isLocal: Bool
    var isFavorite: Bool

    var timezone: TimeZone? {
        TimeZone(identifier: timezoneIdentifier)
    }

    var timezoneAbbreviation: String {
        timezone?.abbreviation() ?? timezoneIdentifier
    }

    var flagEmoji: String {
        let countryCode = countryCodeFromTimezone()
        return countryCodeToEmoji(countryCode)
    }

    private func countryCodeFromTimezone() -> String {
        guard let tz = timezone else { return "🌍" }
        let parts = tz.identifier.split(separator: "/")
        guard parts.count >= 1 else { return "🌍" }

        let region = String(parts[0])
        switch region {
        case "America": return "US"
        case "Europe": return "EU"
        case "Asia": return "AS"
        case "Africa": return "AF"
        case "Australia", "Pacific": return "AU"
        default: return "🌍"
        }
    }

    private func countryCodeToEmoji(_ code: String) -> String {
        let base: UInt32 = 127397
        var emoji = ""
        for scalar in code.uppercased().unicodeScalars {
            emoji.append(String(UnicodeScalar(base + scalar.value)!))
        }
        return emoji
    }
}
