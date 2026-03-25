import Foundation
import SwiftUI
import Combine
import AppKit

@MainActor
class AppState: ObservableObject {
    @Published var cities: [City] = []
    @Published var showingAddCity = false
    @Published var showingSettings = false
    @Published var selectedCityId: UUID?
    @Published var currentTime = Date()
    @Published var use24HourFormat: Bool

    var popover: NSPopover?

    private var timer: Timer?
    private let cityStore: CityStore
    private let settingsStore: SettingsStore

    init() {
        self.settingsStore = SettingsStore()
        self.cityStore = CityStore()
        self.use24HourFormat = settingsStore.getBool(forKey: "use24HourFormat") ?? false

        loadCities()
        startTimer()
    }

    deinit {
        timer?.invalidate()
    }

    func loadCities() {
        cities = cityStore.loadCities()
        if cities.isEmpty {
            // Add default cities
            let defaults = [
                City(name: "New York", country: "United States", timezoneIdentifier: "America/New_York", sortOrder: 0, isLocal: false),
                City(name: "London", country: "United Kingdom", timezoneIdentifier: "Europe/London", sortOrder: 1, isLocal: false),
                City(name: "Tokyo", country: "Japan", timezoneIdentifier: "Asia/Tokyo", sortOrder: 2, isLocal: false)
            ]
            for city in defaults {
                cityStore.saveCity(city)
            }
            cities = cityStore.loadCities()
        }
    }

    func addCity(_ city: City) {
        var newCity = city
        newCity.sortOrder = cities.count
        cityStore.saveCity(newCity)
        cities = cityStore.loadCities()
    }

    func removeCity(_ city: City) {
        cityStore.deleteCity(city)
        cities = cityStore.loadCities()
    }

    func moveCity(from source: IndexSet, to destination: Int) {
        var mutableCities = cities
        mutableCities.move(fromOffsets: source, toOffset: destination)
        for (index, var city) in mutableCities.enumerated() {
            city.sortOrder = index
            cityStore.saveCity(city)
        }
        cities = cityStore.loadCities()
    }

    func setUse24HourFormat(_ value: Bool) {
        use24HourFormat = value
        settingsStore.set(value, forKey: "use24HourFormat")
    }

    func refreshTimes() {
        currentTime = Date()
    }

    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.currentTime = Date()
            }
        }
    }
}
