import SwiftUI

struct ZoneListView: View {
    @ObservedObject var appState: AppState

    var body: some View {
        List {
            // Local time
            LocalTimeRowView()

            Divider()

            // Cities
            ForEach(appState.cities) { city in
                ZoneRowView(city: city, currentTime: appState.currentTime, use24Hour: appState.use24HourFormat)
            }
            .onDelete(perform: deleteCity)
            .onMove(perform: moveCity)
        }
        .listStyle(.inset)
    }

    private func deleteCity(at offsets: IndexSet) {
        for index in offsets {
            if index < appState.cities.count {
                appState.removeCity(appState.cities[index])
            }
        }
    }

    private func moveCity(from source: IndexSet, to destination: Int) {
        appState.moveCity(from: source, to: destination)
    }
}
