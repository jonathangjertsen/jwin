import SwiftUI
import UserNotifications

/// View of random stuff for debugging
struct DebugView: View {
    @ObservedObject var appState: AppState
    var appStateUrl: URL
    @ObservedObject var lastStateSave: DatePoke
    
    /// List of pending notifications
    @State private var pendingNotifications: [UNNotificationRequest] = []
    
    /// Set to true if an alert should show
    @State private var showingSaveAlert = false
    
    /// Text to show in the save alert, if any
    @State private var saveAlertText: String = ""
    
    var body: some View {
        Form {
            /// Shows where the state was loaded from
            Section(header: Text("State URL")) {
                Text("\(self.appStateUrl)").font(.footnote)
            }

            /// Shows when the state was last saved
            Section(header: Text("Last save time")) {
                Text("\(self.lastStateSave.lastPoked)")
            }
            
            /// Shows whether permissions have been granted
            Section(header: Text("Permissions granted?")) {
                Text("\(self.appState.config.permissionsGranted ? "Yes" : "No")")
            }
            
            /// Shows a list of all pending notifications and allows for them to be deleted
            if !self.pendingNotifications.isEmpty {
                Section(header: Text("Pending notifications")) {
                    ForEach(self.pendingNotifications, id:\.identifier) {
                        notification in
                        HStack {
                            VStack(alignment: .leading) {
                                Text("Title: \(notification.content.title)")
                                    .font(.caption)
                                Text("Date: \(notification.printableTrigger())")
                                    .font(.caption)
                                Text("UUID: \(notification.identifier)")
                                    .font(.caption)
                            }

                            Spacer()

                            Button(action: {
                                UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [
                                    notification.identifier
                                ])
                                self.checkPendingNotifications()
                            }) {
                                Image(systemName: "trash")
                                    .foregroundColor(.red)
                                    .padding()
                            }
                        }
                    }
                }
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
                
                /// Button for  checking pending notifications
                Button(action: self.checkPendingNotifications) {
                    Text("Check pending notifications")
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
        
        /// Check pending notifications on view
        .onAppear {
            self.checkPendingNotifications()
        }
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
        let content = UNMutableNotificationContent()
        content.title = "Demo notification content with delay of 2 seconds"
        content.categoryIdentifier = "alarm"
        content.sound = UNNotificationSound.default

        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: UNCalendarNotificationTrigger(dateMatching: Calendar.current.dateComponents(
                [.year, .month, .day, .hour, .minute, .second],
                from: Date().addingTimeInterval(2.0)
            ), repeats: false)
        )

        UNUserNotificationCenter.current().add(request)
        
        self.checkPendingNotifications()
    }
    
    /// Requests permissions for the app
    func requestPermissions() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) {
            (granted, error) in
            inMainThread {
                self.appState.permissions(granted: granted)
            }
        }
    }
    
    /// Check pending ontifications
    func checkPendingNotifications() {
        UNUserNotificationCenter.current().getPendingNotificationRequests {
            requests in
            self.pendingNotifications = requests
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
