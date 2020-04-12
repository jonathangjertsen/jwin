import SwiftUI

/// Main tabbed app view
struct AppView: View {
    @ObservedObject var appState: AppState
    var appStateUrl: URL
    var lastStateSave: DatePoke

    @State private var showingFailureToSaveAlert = false

    var body: some View {
        /// Show a tabbed view (tabs at the bottom linking to each sub-app)
        TabView {
            /// The "list of lists" view with a list icon on the tab
            ListOfListsView(
                appState: self.appState
            )
                .tabItem {
                    Image(systemName: "list.dash")
                    Text("Lists")
                }
            
            /// The debug view with an appropriate icon
            DebugView(
                appState: self.appState,
                appStateUrl: self.appStateUrl,
                lastStateSave: self.lastStateSave
            )
                .tabItem {
                    Image(systemName: "gauge")
                    Text("Debug")
                }
        }
        .alert(isPresented: $showingFailureToSaveAlert) {
            Alert(
                title: Text("Failed to auto-save"),
                message: Text("Failed to auto-save for some reason. Go to Debug -> Save to save manually. Last successful sync was at time \(self.lastStateSave.lastPoked)"),
                dismissButton: .default(Text("OK"))
            )
        }
    }
    
    func saveFail() {
        self.showingFailureToSaveAlert = true
    }
    
    func saveSuccess() {
        self.lastStateSave.poke()
    }
}

struct AppView_Previews: PreviewProvider {
    static var previews: some View {
        AppView(
            appState: AppState.loadDemo(),
            appStateUrl: AppState.demoUrl(),
            lastStateSave: DatePoke()
        )
    }
}
