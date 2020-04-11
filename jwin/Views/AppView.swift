import SwiftUI

/// Main tabbed app view
struct AppView: View {
    @ObservedObject var appState: AppState
    var appStateUrl: URL

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
                appStateUrl: self.appStateUrl
            )
                .tabItem {
                    Image(systemName: "gauge")
                    Text("Debug")
                }
        }
    }
}

struct AppView_Previews: PreviewProvider {
    static var previews: some View {
        AppView(
            appState: AppState.loadDemo(),
            appStateUrl: AppState.demoUrl()
        )
    }
}
