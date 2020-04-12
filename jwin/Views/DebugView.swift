import SwiftUI

/// View of random stuff for debugging
struct DebugView: View {
    @ObservedObject var appState: AppState
    var appStateUrl: URL
    @ObservedObject var lastStateSave: DatePoke
    
    /// Set to true if an alert should show
    @State private var showingSaveAlert = false
    
    /// Text to show in the save alert, if any
    @State private var saveAlertText: String = ""
    
    var body: some View {
        VStack {
            /// Shows where the state was loaded from
            /// Kinda ugly, but OK since it is just debug info
            HStack {
                Text("State URL").bold()
                Text("\(self.appStateUrl)")
            }.padding()

            HStack {
                Text("Last save").bold()
                Text("\(self.lastStateSave.lastPoked)")
            }.padding()
            
            /// Spacer to move the info to the top and the buttons to the end
            Spacer()

            /// Button for storing the app state
            Button(action: self.storeAppState) {
                Text("Save state")
            }.padding()
        }

        /// Alert showing the result of saving
        .alert(isPresented: $showingSaveAlert) {
            Alert(
                title: Text("Result of save"),
                message: Text(self.saveAlertText),
                dismissButton: .default(Text("OK"))
            )
        }

        /// Nav bar
        .navigationBarTitle("Debug")
    }

    /// Stores the app state immediately and triggers an alert with info on whether it succeeded
    func storeAppState() {
        self.appState.saveDefault(onSuccess: {
            url in
            /// Show text indicating success (only when saving explicitly)
            self.saveAlertText = "Successfully wrote to \(url)"
            self.lastStateSave.poke()
        }, onError: {
            url in
            /// Show an appropriate text depending on whether we got the right URL
            if let url = url {
                self.saveAlertText = "Failed writing to \(url)"
            } else {
                self.saveAlertText = "Failed getting an URL"
            }
        })
        
        /// Indicate that we would like to show the alert now
        self.showingSaveAlert = true
    }
}

struct DebugView_Previews: PreviewProvider {
    static var previews: some View {
        DebugView(
            appState: AppState.loadDemo(),
            appStateUrl: AppState.demoUrl(),
            lastStateSave: DatePoke()
        )
    }
}
