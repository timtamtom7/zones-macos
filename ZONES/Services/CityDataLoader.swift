import Foundation

class CityDataLoader {
    static let shared = CityDataLoader()

    private(set) var allCities: [CityDataEntry] = []

    private init() {
        loadCities()
    }

    private func loadCities() {
        // Embedded city database - major world cities
        let cityList: [[String: String]] = [
            ["name": "New York", "country": "United States", "timezone": "America/New_York", "countryCode": "US"],
            ["name": "Los Angeles", "country": "United States", "timezone": "America/Los_Angeles", "countryCode": "US"],
            ["name": "Chicago", "country": "United States", "timezone": "America/Chicago", "countryCode": "US"],
            ["name": "Houston", "country": "United States", "timezone": "America/Chicago", "countryCode": "US"],
            ["name": "Phoenix", "country": "United States", "timezone": "America/Phoenix", "countryCode": "US"],
            ["name": "San Francisco", "country": "United States", "timezone": "America/Los_Angeles", "countryCode": "US"],
            ["name": "Seattle", "country": "United States", "timezone": "America/Los_Angeles", "countryCode": "US"],
            ["name": "Denver", "country": "United States", "timezone": "America/Denver", "countryCode": "US"],
            ["name": "Boston", "country": "United States", "timezone": "America/New_York", "countryCode": "US"],
            ["name": "Miami", "country": "United States", "timezone": "America/New_York", "countryCode": "US"],
            ["name": "London", "country": "United Kingdom", "timezone": "Europe/London", "countryCode": "GB"],
            ["name": "Manchester", "country": "United Kingdom", "timezone": "Europe/London", "countryCode": "GB"],
            ["name": "Edinburgh", "country": "United Kingdom", "timezone": "Europe/London", "countryCode": "GB"],
            ["name": "Paris", "country": "France", "timezone": "Europe/Paris", "countryCode": "FR"],
            ["name": "Berlin", "country": "Germany", "timezone": "Europe/Berlin", "countryCode": "DE"],
            ["name": "Munich", "country": "Germany", "timezone": "Europe/Berlin", "countryCode": "DE"],
            ["name": "Frankfurt", "country": "Germany", "timezone": "Europe/Berlin", "countryCode": "DE"],
            ["name": "Amsterdam", "country": "Netherlands", "timezone": "Europe/Amsterdam", "countryCode": "NL"],
            ["name": "Brussels", "country": "Belgium", "timezone": "Europe/Brussels", "countryCode": "BE"],
            ["name": "Madrid", "country": "Spain", "timezone": "Europe/Madrid", "countryCode": "ES"],
            ["name": "Barcelona", "country": "Spain", "timezone": "Europe/Madrid", "countryCode": "ES"],
            ["name": "Rome", "country": "Italy", "timezone": "Europe/Rome", "countryCode": "IT"],
            ["name": "Milan", "country": "Italy", "timezone": "Europe/Rome", "countryCode": "IT"],
            ["name": "Vienna", "country": "Austria", "timezone": "Europe/Vienna", "countryCode": "AT"],
            ["name": "Zurich", "country": "Switzerland", "timezone": "Europe/Zurich", "countryCode": "CH"],
            ["name": "Geneva", "country": "Switzerland", "timezone": "Europe/Zurich", "countryCode": "CH"],
            ["name": "Stockholm", "country": "Sweden", "timezone": "Europe/Stockholm", "countryCode": "SE"],
            ["name": "Copenhagen", "country": "Denmark", "timezone": "Europe/Copenhagen", "countryCode": "DK"],
            ["name": "Oslo", "country": "Norway", "timezone": "Europe/Oslo", "countryCode": "NO"],
            ["name": "Helsinki", "country": "Finland", "timezone": "Europe/Helsinki", "countryCode": "FI"],
            ["name": "Dublin", "country": "Ireland", "timezone": "Europe/Dublin", "countryCode": "IE"],
            ["name": "Lisbon", "country": "Portugal", "timezone": "Europe/Lisbon", "countryCode": "PT"],
            ["name": "Warsaw", "country": "Poland", "timezone": "Europe/Warsaw", "countryCode": "PL"],
            ["name": "Prague", "country": "Czech Republic", "timezone": "Europe/Prague", "countryCode": "CZ"],
            ["name": "Budapest", "country": "Hungary", "timezone": "Europe/Budapest", "countryCode": "HU"],
            ["name": "Athens", "country": "Greece", "timezone": "Europe/Athens", "countryCode": "GR"],
            ["name": "Istanbul", "country": "Turkey", "timezone": "Europe/Istanbul", "countryCode": "TR"],
            ["name": "Moscow", "country": "Russia", "timezone": "Europe/Moscow", "countryCode": "RU"],
            ["name": "St. Petersburg", "country": "Russia", "timezone": "Europe/Moscow", "countryCode": "RU"],
            ["name": "Tokyo", "country": "Japan", "timezone": "Asia/Tokyo", "countryCode": "JP"],
            ["name": "Osaka", "country": "Japan", "timezone": "Asia/Tokyo", "countryCode": "JP"],
            ["name": "Seoul", "country": "South Korea", "timezone": "Asia/Seoul", "countryCode": "KR"],
            ["name": "Beijing", "country": "China", "timezone": "Asia/Shanghai", "countryCode": "CN"],
            ["name": "Shanghai", "country": "China", "timezone": "Asia/Shanghai", "countryCode": "CN"],
            ["name": "Hong Kong", "country": "Hong Kong", "timezone": "Asia/Hong_Kong", "countryCode": "HK"],
            ["name": "Taipei", "country": "Taiwan", "timezone": "Asia/Taipei", "countryCode": "TW"],
            ["name": "Singapore", "country": "Singapore", "timezone": "Asia/Singapore", "countryCode": "SG"],
            ["name": "Bangkok", "country": "Thailand", "timezone": "Asia/Bangkok", "countryCode": "TH"],
            ["name": "Kuala Lumpur", "country": "Malaysia", "timezone": "Asia/Kuala_Lumpur", "countryCode": "MY"],
            ["name": "Jakarta", "country": "Indonesia", "timezone": "Asia/Jakarta", "countryCode": "ID"],
            ["name": "Manila", "country": "Philippines", "timezone": "Asia/Manila", "countryCode": "PH"],
            ["name": "Ho Chi Minh City", "country": "Vietnam", "timezone": "Asia/Ho_Chi_Minh", "countryCode": "VN"],
            ["name": "Hanoi", "country": "Vietnam", "timezone": "Asia/Ho_Chi_Minh", "countryCode": "VN"],
            ["name": "Mumbai", "country": "India", "timezone": "Asia/Kolkata", "countryCode": "IN"],
            ["name": "New Delhi", "country": "India", "timezone": "Asia/Kolkata", "countryCode": "IN"],
            ["name": "Bangalore", "country": "India", "timezone": "Asia/Kolkata", "countryCode": "IN"],
            ["name": "Chennai", "country": "India", "timezone": "Asia/Kolkata", "countryCode": "IN"],
            ["name": "Kolkata", "country": "India", "timezone": "Asia/Kolkata", "countryCode": "IN"],
            ["name": "Dubai", "country": "United Arab Emirates", "timezone": "Asia/Dubai", "countryCode": "AE"],
            ["name": "Abu Dhabi", "country": "United Arab Emirates", "timezone": "Asia/Dubai", "countryCode": "AE"],
            ["name": "Doha", "country": "Qatar", "timezone": "Asia/Qatar", "countryCode": "QA"],
            ["name": "Riyadh", "country": "Saudi Arabia", "timezone": "Asia/Riyadh", "countryCode": "SA"],
            ["name": "Tel Aviv", "country": "Israel", "timezone": "Asia/Jerusalem", "countryCode": "IL"],
            ["name": "Jerusalem", "country": "Israel", "timezone": "Asia/Jerusalem", "countryCode": "IL"],
            ["name": "Sydney", "country": "Australia", "timezone": "Australia/Sydney", "countryCode": "AU"],
            ["name": "Melbourne", "country": "Australia", "timezone": "Australia/Melbourne", "countryCode": "AU"],
            ["name": "Brisbane", "country": "Australia", "timezone": "Australia/Brisbane", "countryCode": "AU"],
            ["name": "Perth", "country": "Australia", "timezone": "Australia/Perth", "countryCode": "AU"],
            ["name": "Auckland", "country": "New Zealand", "timezone": "Pacific/Auckland", "countryCode": "NZ"],
            ["name": "Wellington", "country": "New Zealand", "timezone": "Pacific/Auckland", "countryCode": "NZ"],
            ["name": "Toronto", "country": "Canada", "timezone": "America/Toronto", "countryCode": "CA"],
            ["name": "Vancouver", "country": "Canada", "timezone": "America/Vancouver", "countryCode": "CA"],
            ["name": "Montreal", "country": "Canada", "timezone": "America/Toronto", "countryCode": "CA"],
            ["name": "Calgary", "country": "Canada", "timezone": "America/Edmonton", "countryCode": "CA"],
            ["name": "Mexico City", "country": "Mexico", "timezone": "America/Mexico_City", "countryCode": "MX"],
            ["name": "Guadalajara", "country": "Mexico", "timezone": "America/Mexico_City", "countryCode": "MX"],
            ["name": "Sao Paulo", "country": "Brazil", "timezone": "America/Sao_Paulo", "countryCode": "BR"],
            ["name": "Rio de Janeiro", "country": "Brazil", "timezone": "America/Sao_Paulo", "countryCode": "BR"],
            ["name": "Buenos Aires", "country": "Argentina", "timezone": "America/Argentina/Buenos_Aires", "countryCode": "AR"],
            ["name": "Santiago", "country": "Chile", "timezone": "America/Santiago", "countryCode": "CL"],
            ["name": "Lima", "country": "Peru", "timezone": "America/Lima", "countryCode": "PE"],
            ["name": "Bogota", "country": "Colombia", "timezone": "America/Bogota", "countryCode": "CO"],
            ["name": "Cairo", "country": "Egypt", "timezone": "Africa/Cairo", "countryCode": "EG"],
            ["name": "Lagos", "country": "Nigeria", "timezone": "Africa/Lagos", "countryCode": "NG"],
            ["name": "Johannesburg", "country": "South Africa", "timezone": "Africa/Johannesburg", "countryCode": "ZA"],
            ["name": "Cape Town", "country": "South Africa", "timezone": "Africa/Johannesburg", "countryCode": "ZA"],
            ["name": "Nairobi", "country": "Kenya", "timezone": "Africa/Nairobi", "countryCode": "KE"],
            ["name": "Casablanca", "country": "Morocco", "timezone": "Africa/Casablanca", "countryCode": "MA"],
            ["name": "Honolulu", "country": "United States", "timezone": "Pacific/Honolulu", "countryCode": "US"],
            ["name": "Anchorage", "country": "United States", "timezone": "America/Anchorage", "countryCode": "US"],
        ]

        allCities = cityList.compactMap { dict in
            guard let name = dict["name"],
                  let country = dict["country"],
                  let timezone = dict["timezone"],
                  let code = dict["countryCode"] else {
                return nil
            }
            return CityDataEntry(name: name, country: country, timezone: timezone, countryCode: code)
        }
    }

    func search(query: String) -> [CityDataEntry] {
        guard !query.isEmpty else { return allCities }
        let lower = query.lowercased()
        return allCities.filter { city in
            city.name.lowercased().contains(lower) ||
            city.country.lowercased().contains(lower)
        }
    }
}
