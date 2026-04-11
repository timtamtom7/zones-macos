import SwiftUI

struct AddCitySheet: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) private var dismiss
    @State private var searchText = ""
    @StateObject private var searchVM = CitySearchViewModel()

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Add City")
                    .font(.headline)
                    .fontWeight(.semibold)

                Spacer()

                Button(action: { dismiss() }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(.regularMaterial)
            .clipShape(.rect(cornerRadius: 12, style: .continuous))

            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(.secondary)

                TextField("Search cities", text: $searchText)
                    .textFieldStyle(.plain)
                    .autocorrectionDisabled()
            }
            .padding(10)
            .background(.ultraThinMaterial)
            .clipShape(.rect(cornerRadius: 12, style: .continuous))
            .padding(.horizontal, 16)
            .padding(.vertical, 12)

            ScrollView {
                LazyVStack(spacing: 0) {
                    ForEach(searchVM.filteredCities) { city in
                        CityRowView(city: city)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                addCity(city)
                            }
                    }
                }
            }
            .scrollContentBackground(.hidden)
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
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Text(city.timezone.split(separator: "/").last.map(String.init) ?? city.timezone)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .contentShape(Rectangle())
        .accessibilityLabel("\(city.name), \(city.country), \(city.timezone)")
        .accessibilityHint("Double tap to add this city to your zones")
    }
}
