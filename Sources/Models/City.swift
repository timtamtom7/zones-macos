import Foundation
import SwiftUI

struct City: Identifiable, Codable, Hashable {
    let id: UUID
    var name: String
    var country: String
    var timezoneIdentifier: String
    var sortOrder: Int
    var isLocal: Bool
    var isFavorite: Bool
    var nickname: String?
    var colorHex: String?

    var timezone: TimeZone? {
        TimeZone(identifier: timezoneIdentifier)
    }

    var timezoneAbbreviation: String {
        timezone?.abbreviation() ?? timezoneIdentifier
    }

    var displayName: String {
        nickname ?? name
    }

    var displayColor: Color? {
        guard let hex = colorHex else { return nil }
        return Color(hex: hex)
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

extension Color {
    init?(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.hasPrefix("#") ? String(hexSanitized.dropFirst()) : hexSanitized

        var rgb: UInt64 = 0
        guard Scanner(string: hexSanitized).scanHexInt64(&rgb) else { return nil }

        let r = Double((rgb & 0xFF0000) >> 16) / 255.0
        let g = Double((rgb & 0x00FF00) >> 8) / 255.0
        let b = Double(rgb & 0x0000FF) / 255.0

        self.init(red: r, green: g, blue: b)
    }

    var hexString: String {
        guard let components = NSColor(self).cgColor.components, components.count >= 3 else {
            return "#000000"
        }
        let r = Int(components[0] * 255)
        let g = Int(components[1] * 255)
        let b = Int(components[2] * 255)
        return String(format: "#%02X%02X%02X", r, g, b)
    }
}
