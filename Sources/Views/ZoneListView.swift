import SwiftUI

struct ZoneListView: View {
    @EnvironmentObject var appState: AppState
    @State private var editingCity: City?
    @State private var showEditSheet = false

    var body: some View {
        List {
            ForEach(appState.cities) { city in
                ZoneRowView(city: city)
                    .contextMenu {
                        if !city.isLocal {
                            Button {
                                editingCity = city
                                showEditSheet = true
                            } label: {
                                Label("Edit", systemImage: "pencil")
                            }
                        }
                    }
                    .swipeActions(edge: .trailing) {
                        if !city.isLocal {
                            Button(role: .destructive) {
                                appState.removeCity(city)
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                    }
                    .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16))
                    .listRowSeparator(.hidden)
            }
            .onMove { source, destination in
                appState.moveCity(from: source, to: destination)
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .sheet(isPresented: $showEditSheet) {
            if let city = editingCity,
               let index = appState.cities.firstIndex(where: { $0.id == city.id }) {
                EditCitySheet(city: $appState.cities[index])
            }
        }
    }
}
