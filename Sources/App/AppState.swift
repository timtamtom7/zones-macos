import Foundation
import Combine

@MainActor
class AppState: ObservableObject {
    static let shared = AppState()

    @Published var cities: [City] = []
    @Published var showAddCitySheet = false
    @Published var showSettings = false
    @Published var use24HourFormat = false
    @Published var currentTime = Date()
    @Published var lastError: Error?

    private var timer: Timer?
    private let cityStore = CityStore.shared
    private let timeFormatter = TimeFormatterService.shared

    private init() {
        loadCities()
        startTimer()
    }

    var localCity: City? {
        cities.first { $0.isLocal }
    }

    var menuBarTimeString: String {
        timeFormatter.formatTime(currentTime, timezone: .current, use24Hour: use24HourFormat)
    }

    func loadCities() {
        do {
            cities = try cityStore.getAllCities()
            if cities.isEmpty {
                setupDefaultCities()
            }
            lastError = nil
        } catch {
            lastError = error
            cities = []
        }
    }

    private func setupDefaultCities() {
        let defaults = [
            ("New York", "United States", "America/New_York"),
            ("London", "United Kingdom", "Europe/London"),
            ("Tokyo", "Japan", "Asia/Tokyo")
        ]

        let localCity = City(
            id: UUID(),
            name: "Local",
            country: "",
            timezoneIdentifier: TimeZone.current.identifier,
            sortOrder: 0,
            isLocal: true,
            isFavorite: false
        )
        try? cityStore.saveCity(localCity)

        for (index, (name, country, tz)) in defaults.enumerated() {
            let city = City(
                id: UUID(),
                name: name,
                country: country,
                timezoneIdentifier: tz,
                sortOrder: index + 1,
                isLocal: false,
                isFavorite: false
            )
            try? cityStore.saveCity(city)
        }

        loadCities()
    }

    func addCity(_ cityData: CityData) {
        let city = City(
            id: UUID(),
            name: cityData.name,
            country: cityData.country,
            timezoneIdentifier: cityData.timezone,
            sortOrder: cities.count,
            isLocal: false,
            isFavorite: false
        )
        do {
            try cityStore.saveCity(city)
            loadCities()
        } catch {
            lastError = error
        }
    }

    func removeCity(_ city: City) {
        do {
            try cityStore.deleteCity(city.id)
            loadCities()
        } catch {
            lastError = error
        }
    }

    func moveCity(from source: IndexSet, to destination: Int) {
        var reorderedCities = cities
        reorderedCities.move(fromOffsets: source, toOffset: destination)
        for (index, var city) in reorderedCities.enumerated() {
            city.sortOrder = index
            try? cityStore.updateCity(city)
        }
        loadCities()
    }

    func updateCity(_ city: City) {
        do {
            try cityStore.updateCity(city)
            loadCities()
        } catch {
            lastError = error
        }
    }

    func refreshTimes() {
        currentTime = Date()
    }

    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.refreshTimes()
            }
        }
    }

    deinit {
        timer?.invalidate()
    }
}
