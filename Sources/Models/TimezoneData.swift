import Foundation

struct CityData: Identifiable, Codable, Hashable {
    let id: UUID
    let name: String
    let country: String
    let timezone: String
    let countryCode: String

    init(name: String, country: String, timezone: String, countryCode: String = "") {
        self.id = UUID()
        self.name = name
        self.country = country
        self.timezone = timezone
        self.countryCode = countryCode
    }

    var flagEmoji: String {
        let code = countryCode.isEmpty ? countryCodeFromTimezone() : countryCode.uppercased()
        return countryCodeToEmoji(code)
    }

    private func countryCodeFromTimezone() -> String {
        let parts = timezone.split(separator: "/")
        guard let region = parts.first else { return "🌍" }
        switch String(region) {
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

struct CityDatabase {
    static let cities: [CityData] = [
        // North America
        CityData(name: "New York", country: "United States", timezone: "America/New_York", countryCode: "US"),
        CityData(name: "Los Angeles", country: "United States", timezone: "America/Los_Angeles", countryCode: "US"),
        CityData(name: "Chicago", country: "United States", timezone: "America/Chicago", countryCode: "US"),
        CityData(name: "Houston", country: "United States", timezone: "America/Chicago", countryCode: "US"),
        CityData(name: "Phoenix", country: "United States", timezone: "America/Phoenix", countryCode: "US"),
        CityData(name: "San Francisco", country: "United States", timezone: "America/Los_Angeles", countryCode: "US"),
        CityData(name: "Seattle", country: "United States", timezone: "America/Los_Angeles", countryCode: "US"),
        CityData(name: "Denver", country: "United States", timezone: "America/Denver", countryCode: "US"),
        CityData(name: "Boston", country: "United States", timezone: "America/New_York", countryCode: "US"),
        CityData(name: "Miami", country: "United States", timezone: "America/New_York", countryCode: "US"),
        CityData(name: "Toronto", country: "Canada", timezone: "America/Toronto", countryCode: "CA"),
        CityData(name: "Vancouver", country: "Canada", timezone: "America/Vancouver", countryCode: "CA"),
        CityData(name: "Montreal", country: "Canada", timezone: "America/Montreal", countryCode: "CA"),
        CityData(name: "Mexico City", country: "Mexico", timezone: "America/Mexico_City", countryCode: "MX"),

        // Europe
        CityData(name: "London", country: "United Kingdom", timezone: "Europe/London", countryCode: "GB"),
        CityData(name: "Paris", country: "France", timezone: "Europe/Paris", countryCode: "FR"),
        CityData(name: "Berlin", country: "Germany", timezone: "Europe/Berlin", countryCode: "DE"),
        CityData(name: "Rome", country: "Italy", timezone: "Europe/Rome", countryCode: "IT"),
        CityData(name: "Madrid", country: "Spain", timezone: "Europe/Madrid", countryCode: "ES"),
        CityData(name: "Amsterdam", country: "Netherlands", timezone: "Europe/Amsterdam", countryCode: "NL"),
        CityData(name: "Brussels", country: "Belgium", timezone: "Europe/Brussels", countryCode: "BE"),
        CityData(name: "Vienna", country: "Austria", timezone: "Europe/Vienna", countryCode: "AT"),
        CityData(name: "Zurich", country: "Switzerland", timezone: "Europe/Zurich", countryCode: "CH"),
        CityData(name: "Stockholm", country: "Sweden", timezone: "Europe/Stockholm", countryCode: "SE"),
        CityData(name: "Oslo", country: "Norway", timezone: "Europe/Oslo", countryCode: "NO"),
        CityData(name: "Copenhagen", country: "Denmark", timezone: "Europe/Copenhagen", countryCode: "DK"),
        CityData(name: "Helsinki", country: "Finland", timezone: "Europe/Helsinki", countryCode: "FI"),
        CityData(name: "Dublin", country: "Ireland", timezone: "Europe/Dublin", countryCode: "IE"),
        CityData(name: "Lisbon", country: "Portugal", timezone: "Europe/Lisbon", countryCode: "PT"),
        CityData(name: "Athens", country: "Greece", timezone: "Europe/Athens", countryCode: "GR"),
        CityData(name: "Prague", country: "Czech Republic", timezone: "Europe/Prague", countryCode: "CZ"),
        CityData(name: "Warsaw", country: "Poland", timezone: "Europe/Warsaw", countryCode: "PL"),
        CityData(name: "Budapest", country: "Hungary", timezone: "Europe/Budapest", countryCode: "HU"),
        CityData(name: "Moscow", country: "Russia", timezone: "Europe/Moscow", countryCode: "RU"),

        // Asia
        CityData(name: "Tokyo", country: "Japan", timezone: "Asia/Tokyo", countryCode: "JP"),
        CityData(name: "Osaka", country: "Japan", timezone: "Asia/Tokyo", countryCode: "JP"),
        CityData(name: "Seoul", country: "South Korea", timezone: "Asia/Seoul", countryCode: "KR"),
        CityData(name: "Beijing", country: "China", timezone: "Asia/Shanghai", countryCode: "CN"),
        CityData(name: "Shanghai", country: "China", timezone: "Asia/Shanghai", countryCode: "CN"),
        CityData(name: "Hong Kong", country: "China", timezone: "Asia/Hong_Kong", countryCode: "HK"),
        CityData(name: "Singapore", country: "Singapore", timezone: "Asia/Singapore", countryCode: "SG"),
        CityData(name: "Bangkok", country: "Thailand", timezone: "Asia/Bangkok", countryCode: "TH"),
        CityData(name: "Jakarta", country: "Indonesia", timezone: "Asia/Jakarta", countryCode: "ID"),
        CityData(name: "Manila", country: "Philippines", timezone: "Asia/Manila", countryCode: "PH"),
        CityData(name: "Kuala Lumpur", country: "Malaysia", timezone: "Asia/Kuala_Lumpur", countryCode: "MY"),
        CityData(name: "Mumbai", country: "India", timezone: "Asia/Kolkata", countryCode: "IN"),
        CityData(name: "New Delhi", country: "India", timezone: "Asia/Kolkata", countryCode: "IN"),
        CityData(name: "Bangalore", country: "India", timezone: "Asia/Kolkata", countryCode: "IN"),
        CityData(name: "Dubai", country: "UAE", timezone: "Asia/Dubai", countryCode: "AE"),
        CityData(name: "Taipei", country: "Taiwan", timezone: "Asia/Taipei", countryCode: "TW"),
        CityData(name: "Hanoi", country: "Vietnam", timezone: "Asia/Ho_Chi_Minh", countryCode: "VN"),
        CityData(name: "Istanbul", country: "Turkey", timezone: "Europe/Istanbul", countryCode: "TR"),

        // Oceania
        CityData(name: "Sydney", country: "Australia", timezone: "Australia/Sydney", countryCode: "AU"),
        CityData(name: "Melbourne", country: "Australia", timezone: "Australia/Melbourne", countryCode: "AU"),
        CityData(name: "Brisbane", country: "Australia", timezone: "Australia/Brisbane", countryCode: "AU"),
        CityData(name: "Perth", country: "Australia", timezone: "Australia/Perth", countryCode: "AU"),
        CityData(name: "Auckland", country: "New Zealand", timezone: "Pacific/Auckland", countryCode: "NZ"),
        CityData(name: "Wellington", country: "New Zealand", timezone: "Pacific/Auckland", countryCode: "NZ"),

        // South America
        CityData(name: "São Paulo", country: "Brazil", timezone: "America/Sao_Paulo", countryCode: "BR"),
        CityData(name: "Rio de Janeiro", country: "Brazil", timezone: "America/Sao_Paulo", countryCode: "BR"),
        CityData(name: "Buenos Aires", country: "Argentina", timezone: "America/Argentina/Buenos_Aires", countryCode: "AR"),
        CityData(name: "Lima", country: "Peru", timezone: "America/Lima", countryCode: "PE"),
        CityData(name: "Bogotá", country: "Colombia", timezone: "America/Bogota", countryCode: "CO"),
        CityData(name: "Santiago", country: "Chile", timezone: "America/Santiago", countryCode: "CL"),

        // Africa
        CityData(name: "Cairo", country: "Egypt", timezone: "Africa/Cairo", countryCode: "EG"),
        CityData(name: "Johannesburg", country: "South Africa", timezone: "Africa/Johannesburg", countryCode: "ZA"),
        CityData(name: "Cape Town", country: "South Africa", timezone: "Africa/Johannesburg", countryCode: "ZA"),
        CityData(name: "Lagos", country: "Nigeria", timezone: "Africa/Lagos", countryCode: "NG"),
        CityData(name: "Nairobi", country: "Kenya", timezone: "Africa/Nairobi", countryCode: "KE"),
        CityData(name: "Casablanca", country: "Morocco", timezone: "Africa/Casablanca", countryCode: "MA"),
    ]
}
