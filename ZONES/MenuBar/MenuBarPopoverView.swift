import SwiftUI

struct MenuBarPopoverView: View {
    @ObservedObject var appState: AppState

    var body: some View {
        ContentView(appState: appState)
    }
}
