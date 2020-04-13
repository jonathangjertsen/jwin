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
    @State private var showingDebugAlert = false
    
    /// Text to show in the save alert, if any
    @State private var debugAlertText: String = ""
    
    /// Toggle whether the user is logged in
    @State private var loggedIn: Bool = false
    
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
            
            /// Shows cloud persistence
            if self.appState.cloudPersistence != nil {
                Section(header: Text("Cloud persistence")) {
                    return ForEach(self.appState.cloudPersistence!.debugItems(), id: \.key) {
                        debugItem in
                        HStack {
                            Text(debugItem.key)
                            Spacer()
                            Text(debugItem.value).font(.footnote)
                        }
                    }
                }
                
                FirebaseLoginView(
                    loginData: self.appState.cloudPersistence!.loginData,
                    onLogin: self.cloudLogin,
                    onRegister: self.cloudRegister
                )
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
                

                if self.appState.cloudPersistence != nil {
                    /// Button for storing the app state to the cloud
                    Button(action: self.storeAppStateToCloud) {
                        Text("Save state to cloud")
                    }.disabled(!self.appState.cloudPersistence!.loggedIn)
                    
                    /// Button for storing the app state to the cloud
                    Button(action: self.loadAppStateFromCloud) {
                        Text("Load state from cloud")
                    }.disabled(!self.appState.cloudPersistence!.loggedIn)
                }
            }
        }

        /// Alert showing the result of saving
        .alert(isPresented: $showingDebugAlert) {
            Alert(
                title: Text("Debug event"),
                message: Text(self.debugAlertText),
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
            self.debugAlertText = "Successfully wrote to \(url)"
            self.lastStateSave.poke()
        }, onError: {
            url in
            /// Show an appropriate text depending on whether we got the right URL
            if let url = url {
                self.debugAlertText = "Failed writing to \(url)"
            } else {
                self.debugAlertText = "Failed getting an URL"
            }
        })
        
        /// Indicate that we would like to show the alert now
        self.showingDebugAlert = true
    }
    
    /// Log in to the cloud provider
    func cloudLogin(loginData: LoginData) {
        guard let cloudPersistence = self.appState.cloudPersistence else {
            self.showAlert(text: "Can not log in: cloud persistence has not been initialized")
            return
        }
        
        cloudPersistence.logIn(with: loginData) {
            err in
            if err == nil {
                self.showAlert(text: "Successfully logged in")
            } else {
                self.showAlert(text: "Error during login")
            }
        }
    }
    
    /// Register at the cloud provider
    func cloudRegister(loginData: LoginData) {
        guard let cloudPersistence = self.appState.cloudPersistence else {
            self.showAlert(text: "Can not register: cloud persistence has not been initialized")
            return
        }
        
        cloudPersistence.register(with: loginData) {
            err in
            if err == nil {
                self.showAlert(text: "Successfully registered")
            } else {
                self.showAlert(text: "Error during registration")
            }
        }
    }
    
    /// Stores the app state to cloud immediately and triggers an alert with info on whether it succeeded
    func storeAppStateToCloud() {
        guard let cloudPersistence = self.appState.cloudPersistence else {
            self.showAlert(text: "Can not store state: persistence has not been initialized")
            return
        }
        
        guard let blob = try? self.appState.dumps() else {
            self.showAlert(text: "Failed to dump app state")
            return
        }
        
        do {
            try cloudPersistence.storeBlob(blob, identifier: "appStateDebug") {
                self.showAlert(text: "Data was stored successfully")
            }
        } catch {
            self.showAlert(text: "Error when storing blob: \(error)")
        }
    }
    
    /// Loads the app state from the cloud and triggers an alert with into on what happened
    func loadAppStateFromCloud() {
        guard let cloudPersistence = self.appState.cloudPersistence else {
            self.showAlert(text: "Can not load state: persistence has not been initialized")
            return
        }
        
        do {
            try cloudPersistence.loadBlob(identifier: "appStateDebug") {
                data in
                guard let data = data else {
                    self.showAlert(text: "loadBlob returned nil data")
                    return
                }
                
                guard let newState = try? AppState.loads(from: data) else {
                    self.showAlert(text: "Failed to load a valid AppState from blob")
                    return
                }
                
                self.appState.replaceAllData(with: newState)
                self.showAlert(text: "Downloaded new state from cloud")
            }
        } catch {
            self.showAlert(text: String(describing: error))
        }
    }
    
    /// Shows an alert.
    func showAlert(text: String) {
        self.debugAlertText = text
        self.showingDebugAlert = true
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
            DispatchQueue.main.async {
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
    static let appState = AppState.loadDemo()

    static var previews: some View {
        appState.cloudPersistence = CloudPersistenceMock()
        return DebugView(
            appState: appState,
            appStateUrl: AppState.demoUrl(),
            lastStateSave: DatePoke()
        )
    }
}
