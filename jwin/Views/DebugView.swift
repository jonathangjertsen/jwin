/*
 Random stuff as needed
 */
import SwiftUI

struct DebugView: View {
    @ObservedObject var appState: AppState
    var appStateUrl: URL
    
    @State private var showingSaveAlert = false
    @State private var alertText: String = ""
    
    var body: some View {
        VStack {
            HStack {
                Text("State URL").bold()
                Text("\(self.appStateUrl)")
            }.padding()

            Spacer()

            Button(action: self.storeAppState) {
                Text("Save state")
            }.padding()
        }.alert(isPresented: $showingSaveAlert) {
            Alert(
                title: Text("Result of save"),
                message: Text(self.alertText),
                dismissButton: .default(Text("OK"))
            )
        }.navigationBarTitle("Debug")
    }
    
    func storeAppState() {
        self.appState.saveDefault(onSuccess: {
            url in
            self.alertText = "Successfully wrote to \(url)"
        }, onError: {
            url in
            if let url = url {
                self.alertText = "Failed writing to \(url)"
            } else {
                self.alertText = "Failed getting an URL"
            }
        })
        self.showingSaveAlert = true
    }
}

struct DebugView_Previews: PreviewProvider {
    static let appState = AppState.loadDemo()
    static var previews: some View {
        DebugView(appState: appState, appStateUrl: AppState.demoUrl())
    }
}
