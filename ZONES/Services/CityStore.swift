import Foundation

class CityStore {
    private let db = DatabaseManager.shared

    func loadCities() -> [City] {
        return db.loadCities()
    }

    func saveCity(_ city: City) {
        db.saveCity(city)
    }

    func deleteCity(_ city: City) {
        db.deleteCity(city)
    }
}
