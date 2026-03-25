import SwiftUI

struct ZoneListView: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        List {
            ForEach(appState.cities) { city in
                ZoneRowView(city: city)
                    .swipeActions(edge: .trailing) {
                        if !city.isLocal {
                            Button(role: .destructive) {
                                appState.removeCity(city)
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                    }
            }
            .onMove { source, destination in
                appState.moveCity(from: source, to: destination)
            }
        }
        .listStyle(.plain)
    }
}
