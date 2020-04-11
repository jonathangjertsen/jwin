import SwiftUI

struct AppView: View {
    @ObservedObject var appState: AppState
    var appStateUrl: URL

    var body: some View {
        TabView {
            ListOfListsView(appState: self.appState)
                .tabItem {
                    Image(systemName: "list.dash")
                    Text("Lists")
                }
            
            DebugView(appState: self.appState, appStateUrl: self.appStateUrl)
                .tabItem {
                    Image(systemName: "gauge")
                    Text("Debug")
                }
        }
    }
}

struct AppView_Previews: PreviewProvider {
    static let appState = AppState.loadDemo()
    static var previews: some View {
        AppView(appState: appState, appStateUrl: AppState.demoUrl())
    }
}
