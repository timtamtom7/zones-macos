import SwiftUI

struct AddCitySheet: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) private var dismiss
    @State private var searchText = ""
    @StateObject private var searchVM = CitySearchViewModel()

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("Add City")
                    .font(.headline)

                Spacer()

                Button(action: { dismiss() }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                }
                .buttonStyle(.plain)
            }
            .padding()

            // Search
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)

                TextField("Search cities...", text: $searchText)
                    .textFieldStyle(.plain)
                    .autocorrectionDisabled()
            }
            .padding(8)
            .background(Color(NSColor.controlBackgroundColor))
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .padding(.horizontal)
            .padding(.bottom, 8)

            Divider()

            // Results
            List(searchVM.filteredCities) { city in
                CityRowView(city: city)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        addCity(city)
                    }
            }
            .listStyle(.plain)
        }
        .frame(width: 400, height: 500)
        .onChange(of: searchText) { newValue in
            searchVM.search(query: newValue)
        }
        .onAppear {
            searchVM.loadCities()
        }
    }

    private func addCity(_ cityData: CityData) {
        appState.addCity(cityData)
        dismiss()
    }
}

struct CityRowView: View {
    let city: CityData

    var body: some View {
        HStack(spacing: 12) {
            Text(city.flagEmoji)
                .font(.title2)

            VStack(alignment: .leading, spacing: 2) {
                Text(city.name)
                    .fontWeight(.medium)

                Text(city.country)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            Text(city.timezone.split(separator: "/").last.map(String.init) ?? city.timezone)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 6)
        .contentShape(Rectangle())
    }
}
