import SwiftUI

struct AddCitySheet: View {
    @ObservedObject var appState: AppState
    @Environment(\.dismiss) var dismiss
    @State private var searchText = ""

    private var filteredCities: [CityDataEntry] {
        CityDataLoader.shared.search(query: searchText)
    }

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("Add City")
                    .font(.headline)
                Spacer()
                Button("Cancel") { dismiss() }
            }
            .padding()

            // Search
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                TextField("Search by city or country...", text: $searchText)
                    .textFieldStyle(.plain)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color(NSColor.textBackgroundColor))

            Divider()

            // City list
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 0) {
                    ForEach(filteredCities) { entry in
                        CityRowView(entry: entry) {
                            addCity(entry)
                        }
                        Divider()
                    }
                }
            }
        }
        .frame(width: 360, height: 420)
    }

    private func addCity(_ entry: CityDataEntry) {
        let city = City(
            name: entry.name,
            country: entry.country,
            timezoneIdentifier: entry.timezone,
            sortOrder: appState.cities.count,
            isLocal: false,
            isFavorite: false
        )
        appState.addCity(city)
        dismiss()
    }
}

struct CityRowView: View {
    let entry: CityDataEntry
    let onSelect: () -> Void

    private var flagEmoji: String {
        let base: UInt32 = 127397
        var emoji = ""
        for scalar in entry.countryCode.uppercased().unicodeScalars {
            if let unicode = UnicodeScalar(base + scalar.value) {
                emoji.append(Character(unicode))
            }
        }
        return emoji.count == 2 ? emoji : "🌍"
    }

    var body: some View {
        Button(action: onSelect) {
            HStack {
                Text(flagEmoji)
                    .font(.system(size: 18))
                VStack(alignment: .leading, spacing: 2) {
                    Text(entry.name)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.primary)
                    Text(entry.country)
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                }
                Spacer()
                Text(entry.timezone)
                    .font(.system(size: 10))
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
        }
        .buttonStyle(.plain)
    }
}

struct CitySearchView: View {
    @StateObject private var viewModel = CitySearchViewModel()

    var body: some View {
        List(viewModel.filteredCities) { entry in
            CityRowView(entry: entry) {
                // Handle selection
            }
        }
    }
}
