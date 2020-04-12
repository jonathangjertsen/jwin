import SwiftUI
import UserNotifications

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
        Form {
            /// Shows where the state was loaded from
            /// Kinda ugly, but OK since it is just debug info
            Section(header: Text("State URL")) {
                Text("\(self.appStateUrl)")
            }

            Section(header: Text("Last save time")) {
                Text("\(self.lastStateSave.lastPoked)")
            }
            
            Section(header: Text("Permissions granted?")) {
                Text("\(self.appState.config.permissionsGranted ? "Yes" : "No")")
            }
            
            Section(header: Text("Actions")) {
                /// Button for sending a demo notification
                Button(action: self.sendDemoNotification) {
                    Text("Send demo notification")
                }
                
                /// Button for  requesting permissions
                Button(action: self.requestPermissions) {
                    Text("Request permissions")
                }
                
                /// Button for storing the app state
                Button(action: self.storeAppState) {
                    Text("Save state")
                }
            }
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
    
    /// Sends a demo notification after 2 s
    func sendDemoNotification() {
        let center = UNUserNotificationCenter.current()
        let content = UNMutableNotificationContent()
        content.title = "Demo notification"
        content.body = "Demo notification content"
        content.categoryIdentifier = "alarm"
        content.userInfo = ["customDate": "fizzbuss"]
        content.sound = UNNotificationSound.default

        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: UNCalendarNotificationTrigger(dateMatching: Calendar.current.dateComponents(
                [.year, .month, .day, .hour, .minute, .second],
                from: Date().addingTimeInterval(2.0)
            ), repeats: false)
        )
        center.add(request)
    }
    
    /// Requests permissions for the app
    func requestPermissions() {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .badge, .sound]) {
            (granted, error) in
            inMainThread {
                self.appState.permissions(granted: granted)
            }
        }
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
