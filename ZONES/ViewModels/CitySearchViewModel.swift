import Foundation
import Combine

@MainActor
class CitySearchViewModel: ObservableObject {
    @Published var searchText = ""
    @Published var filteredCities: [CityDataEntry] = []

    private let cityLoader = CityDataLoader.shared

    init() {
        filteredCities = cityLoader.allCities
    }

    func search() {
        filteredCities = cityLoader.search(query: searchText)
    }
}
