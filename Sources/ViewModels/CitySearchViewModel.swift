import Foundation
import Combine

@MainActor
class CitySearchViewModel: ObservableObject {
    @Published var filteredCities: [CityData] = []

    private let dataLoader = CityDataLoader.shared
    private var allCities: [CityData] = []

    func loadCities() {
        allCities = dataLoader.getAllCities()
        filteredCities = allCities
    }

    func search(query: String) {
        if query.isEmpty {
            filteredCities = allCities
        } else {
            filteredCities = dataLoader.searchCities(query: query)
        }
    }
}
