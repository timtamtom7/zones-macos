import Foundation
import SQLite

class CityStore: ObservableObject {
    static let shared = CityStore()

    private var db: Connection? { DatabaseManager.shared.getConnection() }
    
    @Published var cities: [City] = []

    private init() {
        loadCities()
    }

    func loadCities() {
        cities = getAllCities()
    }

    func getAllCities() -> [City] {
        guard let db = db else { return [] }

        let cities = Table("cities")
        let id = SQLite.Expression<String>("id")
        let name = SQLite.Expression<String>("name")
        let country = SQLite.Expression<String>("country")
        let timezoneId = SQLite.Expression<String>("timezone_id")
        let sortOrder = SQLite.Expression<Int>("sort_order")
        let isLocal = SQLite.Expression<Bool>("is_local")
        let isFavorite = SQLite.Expression<Bool>("is_favorite")

        var result: [City] = []
        do {
            for row in try db.prepare(cities.order(sortOrder)) {
                let city = City(
                    id: UUID(uuidString: row[id]) ?? UUID(),
                    name: row[name],
                    country: row[country],
                    timezoneIdentifier: row[timezoneId],
                    sortOrder: row[sortOrder],
                    isLocal: row[isLocal],
                    isFavorite: row[isFavorite]
                )
                result.append(city)
            }
        } catch {
            print("Error loading cities: \(error)")
        }
        return result
    }

    func saveCity(_ city: City) {
        guard let db = db else { return }

        let cities = Table("cities")
        let id = SQLite.Expression<String>("id")
        let name = SQLite.Expression<String>("name")
        let country = SQLite.Expression<String>("country")
        let timezoneId = SQLite.Expression<String>("timezone_id")
        let sortOrder = SQLite.Expression<Int>("sort_order")
        let isLocal = SQLite.Expression<Bool>("is_local")
        let isFavorite = SQLite.Expression<Bool>("is_favorite")

        do {
            try db.run(cities.insert(or: .replace,
                id <- city.id.uuidString,
                name <- city.name,
                country <- city.country,
                timezoneId <- city.timezoneIdentifier,
                sortOrder <- city.sortOrder,
                isLocal <- city.isLocal,
                isFavorite <- city.isFavorite
            ))
        } catch {
            print("Error saving city: \(error)")
        }
    }

    func updateCity(_ city: City) {
        saveCity(city)
    }

    func deleteCity(_ cityId: UUID) {
        guard let db = db else { return }

        let cities = Table("cities")
        let id = SQLite.Expression<String>("id")

        let cityRow = cities.filter(id == cityId.uuidString)
        do {
            try db.run(cityRow.delete())
        } catch {
            print("Error deleting city: \(error)")
        }
    }
}
