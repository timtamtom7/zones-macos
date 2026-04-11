import Foundation
import SQLite

enum CityStoreError: LocalizedError {
    case databaseNotAvailable
    case cityNotFound
    case invalidCityData
    case databaseError(Error)
    
    var errorDescription: String? {
        switch self {
        case .databaseNotAvailable:
            return "Database is not available"
        case .cityNotFound:
            return "City not found"
        case .invalidCityData:
            return "Invalid city data"
        case .databaseError(let error):
            return "Database error: \(error.localizedDescription)"
        }
    }
}

@MainActor
class CityStore: ObservableObject {
    static let shared = CityStore()

    private var db: Connection? { DatabaseManager.shared.getConnection() }
    
    @Published var cities: [City] = []
    @Published var lastError: CityStoreError?

    private init() {
        loadCities()
    }

    func loadCities() {
        do {
            cities = try getAllCities()
        } catch {
            lastError = error as? CityStoreError ?? .databaseError(error)
            cities = []
        }
    }

    func getAllCities() throws -> [City] {
        guard let db = db else { throw CityStoreError.databaseNotAvailable }

        let cities = Table("cities")
        let id = SQLite.Expression<String>("id")
        let name = SQLite.Expression<String>("name")
        let country = SQLite.Expression<String>("country")
        let timezoneId = SQLite.Expression<String>("timezone_id")
        let sortOrder = SQLite.Expression<Int>("sort_order")
        let isLocal = SQLite.Expression<Bool>("is_local")
        let isFavorite = SQLite.Expression<Bool>("is_favorite")
        let nickname = SQLite.Expression<String?>("nickname")
        let colorHex = SQLite.Expression<String?>("color_hex")

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
                    isFavorite: row[isFavorite],
                    nickname: row[nickname],
                    colorHex: row[colorHex]
                )
                result.append(city)
            }
        } catch {
            throw CityStoreError.databaseError(error)
        }
        return result
    }

    func saveCity(_ city: City) throws {
        guard let db = db else { throw CityStoreError.databaseNotAvailable }

        let cities = Table("cities")
        let id = SQLite.Expression<String>("id")
        let name = SQLite.Expression<String>("name")
        let country = SQLite.Expression<String>("country")
        let timezoneId = SQLite.Expression<String>("timezone_id")
        let sortOrder = SQLite.Expression<Int>("sort_order")
        let isLocal = SQLite.Expression<Bool>("is_local")
        let isFavorite = SQLite.Expression<Bool>("is_favorite")
        let nickname = SQLite.Expression<String?>("nickname")
        let colorHex = SQLite.Expression<String?>("color_hex")

        do {
            try db.run(cities.insert(or: .replace,
                id <- city.id.uuidString,
                name <- city.name,
                country <- city.country,
                timezoneId <- city.timezoneIdentifier,
                sortOrder <- city.sortOrder,
                isLocal <- city.isLocal,
                isFavorite <- city.isFavorite,
                nickname <- city.nickname,
                colorHex <- city.colorHex
            ))
        } catch {
            throw CityStoreError.databaseError(error)
        }
    }

    func updateCity(_ city: City) throws {
        try saveCity(city)
    }

    func deleteCity(_ cityId: UUID) throws {
        guard let db = db else { throw CityStoreError.databaseNotAvailable }

        let cities = Table("cities")
        let id = SQLite.Expression<String>("id")

        let cityRow = cities.filter(id == cityId.uuidString)
        do {
            try db.run(cityRow.delete())
        } catch {
            throw CityStoreError.databaseError(error)
        }
    }
}
