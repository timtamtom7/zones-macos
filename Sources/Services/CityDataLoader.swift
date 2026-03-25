import Foundation

class CityDataLoader {
    static let shared = CityDataLoader()

    private init() {}

    func searchCities(query: String) -> [CityData] {
        let lowercasedQuery = query.lowercased()
        return CityDatabase.cities.filter { city in
            city.name.lowercased().contains(lowercasedQuery) ||
            city.country.lowercased().contains(lowercasedQuery)
        }
    }

    func getAllCities() -> [CityData] {
        return CityDatabase.cities
    }

    func getCitiesByRegion(_ region: String) -> [CityData] {
        return CityDatabase.cities.filter { $0.timezone.hasPrefix(region) }
    }
}
