import Foundation
import Combine

@MainActor
class ZoneListViewModel: ObservableObject {
    @Published var cities: [City] = []
    @Published var currentTime = Date()

    private var timer: Timer?
    private let cityStore = CityStore()

    init() {
        loadCities()
        startTimer()
    }

    deinit {
        timer?.invalidate()
    }

    func loadCities() {
        cities = cityStore.loadCities()
    }

    func removeCity(at offsets: IndexSet) {
        for index in offsets {
            if index < cities.count {
                cityStore.deleteCity(cities[index])
            }
        }
        loadCities()
    }

    func moveCity(from source: IndexSet, to destination: Int) {
        var mutableCities = cities
        mutableCities.move(fromOffsets: source, toOffset: destination)
        for (index, city) in mutableCities.enumerated() {
            var updated = city
            updated.sortOrder = index
            cityStore.saveCity(updated)
        }
        loadCities()
    }

    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.currentTime = Date()
            }
        }
    }
}
