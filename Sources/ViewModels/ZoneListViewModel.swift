import Foundation
import Combine

@MainActor
class ZoneListViewModel: ObservableObject {
    @Published var cities: [City] = []

    private let cityStore = CityStore.shared

    init() {
        loadCities()
    }

    func loadCities() {
        cities = cityStore.getAllCities()
    }

    func removeCity(at offsets: IndexSet) {
        for index in offsets {
            let city = cities[index]
            if !city.isLocal {
                cityStore.deleteCity(city.id)
            }
        }
        loadCities()
    }

    func moveCity(from source: IndexSet, to destination: Int) {
        var reorderedCities = cities
        reorderedCities.move(fromOffsets: source, toOffset: destination)
        for (index, var city) in reorderedCities.enumerated() {
            city.sortOrder = index
            cityStore.updateCity(city)
        }
        loadCities()
    }
}
