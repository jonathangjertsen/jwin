import SwiftUI

fileprivate extension Reminder {
    /// - Returns: whether the reminder is old
    func isOld() -> Bool {
        return self.time <= Date()
    }
    
    /// - Parameter pendingNotifications: the list of pending notification requests
    /// - Returns: whether the reminder  is associated with an actual pending notification request
    func isActive(given pendingNotifications: [UNNotificationRequest]) -> Bool {
        return self.associatedNotification(given: pendingNotifications) != nil
    }
    
    /// - Parameter pendingNotifications: the list of pending notification requests
    /// - Returns: whether the reminder is out of sync (in the future, but not associated with any pending requests)
    func isOutOfSync(given pendingNotifications: [UNNotificationRequest]) -> Bool {
        return !isOld() && !isActive(given: pendingNotifications)
    }
    
    /// - Parameter pendingNotifications: the list of pending notification requests
    /// - Returns: the associated pending notification request if any, otherwise nil
    func associatedNotification(given pendingNotifications: [UNNotificationRequest]) -> UNNotificationRequest? {
        return pendingNotifications.first {
            $0.identifier == self.id.uuidString
        }
    }
}

fileprivate extension Color {
    static let active = Color.green
    static let old = Color.secondary
    static let outOfSync = Color.orange
    
    /// - Parameters:
    ///   - reminder: the reminder on which the color depends
    ///   - pendingNotifications: the list of pending notification requests
    /// - Returns: a color that depends on whether the reminder is active, old, or out of sync.
    static func dependingOn(
        reminder: Reminder,
        given pendingNotifications: [UNNotificationRequest]
    ) -> Color {
        reminder.isActive(given: pendingNotifications)
            ? Color.active
            : reminder.isOld()
            ? Color.old
            : Color.outOfSync
    }
}

/// View for the "reminders" sub-app
struct RemindView: View {
    @ObservedObject var reminders: Reminders
    @ObservedObject private var newReminder = Reminder.empty()

    /// List of pending notifications
    @State private var pendingNotifications: [UNNotificationRequest] = []

    /// Controls whether to show an alert that adding a reminder failed
    @State private var failedToAddReminderNotification: Bool = false
    
    var body: some View {
        NavigationView {
            VStack {
                List {
                    /// List of reminders, sorted by date
                    ForEach(self.reminders.reminders.sorted(by: { $0.time < $1.time })) {
                        reminder in
                        HStack {
                            /// Show the text on the left
                            Text("\(reminder.text)")
                                .foregroundColor(
                                    .dependingOn(
                                        reminder: reminder,
                                        given: self.pendingNotifications
                                    )
                                )
                            
                            /// Push the two pieces apart
                            Spacer()
                            
                            /// Show the date on the right
                            Text(DateFormatter.reminderFormat.string(
                                from: reminder.time
                            ))
                                .font(.caption)
                                .foregroundColor(
                                    .dependingOn(
                                        reminder: reminder,
                                        given: self.pendingNotifications
                                    )
                                )
                        }
                    }
                    /// Allow for reminders to be deleted
                    .onDelete(perform: self.clearSingle)
                }
                /// Limit the height of the list so that new reminders can be added more easily
                .frame(height: 200)
                
                /// Form for adding a new reminder and stuff
                Form {
                    /// Header for the form
                    Section(header: Text("New reminder")) {
                        /// Text field for what to do
                        TextField("What", text: $newReminder.text)
                        
                        /// Date picker for when to do it
                        DatePicker(selection: $newReminder.time) {
                            Text("When")
                        }
                        
                        /// Button that creates the reminder when pressed
                        CenteredButton(text: "Create", action: self.submitNewReminder)
                    }
                    
                    /// Buttons to clear reminders
                    Section(header: Text("Clear reminders")) {
                        /// Button to clear all reminders and notifications
                        CenteredButton(
                            text: "Clear all + notifications",
                            action: self.clearAll
                        )
                        
                        /// Button to clear only the old and out of sync reminders
                        CenteredButton(
                            text: "Clear old",
                            action: self.clearOldAndOutOfSync
                        )
                    }
                }
            }
            /// Set title in navigation view
            .navigationBarTitle("Reminders")
                
            /// Alert to show if we failed to add a notification for some reason
            .alert(isPresented: $failedToAddReminderNotification) {
                Alert(title: Text("Failed to add notification"))
            }
                
            /// Get the pending notificatinos on load
            .onAppear {
                self.updatePendingNotificationsInView()
            }
        }
    }
    
    /// Check pending ontifications
    func updatePendingNotificationsInView() {
        UNUserNotificationCenter.current().getPendingNotificationRequests {
            requests in
            DispatchQueue.main.async {
                self.pendingNotifications = requests
            }
        }
    }
    
    /// Submit the reminder in the form
    func submitNewReminder() {
        guard let submittedReminder = self.newReminder.submit() else {
            self.failedToAddReminderNotification = true
            return
        }
        self.reminders.add(submittedReminder)
        self.updatePendingNotificationsInView()
    }
    
    /// Clears a  (could in principle clear multiple) reminder and associated notification(s)
    /// - Parameter indices: indices to clear
    func clearSingle(indices: IndexSet) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(
            withIdentifiers: Array(indices.compactMap {
                if let request = self.reminders.reminders[$0].associatedNotification(
                    given: self.pendingNotifications
                ) {
                    return request.identifier
                } else {
                    return nil
                }
            })
        )

        self.reminders.remove(at: indices)
        self.updatePendingNotificationsInView()
    }
    
    /// Clear every reminder and all associated notifications
    func clearAll() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(
            withIdentifiers: Array(Set(self.pendingNotifications.map {
                $0.identifier
            }).union(Set(self.reminders.reminders.map {
                $0.id.uuidString
            })))
        )

        self.reminders.removeAll()
        self.updatePendingNotificationsInView()
    }
    
    /// Clear old and out of sync reminders
    func clearOldAndOutOfSync() {
        let enumeratedReminders = self.reminders.reminders.enumerated()
        let enumeratedOldAndOutOfSyncReminders = enumeratedReminders.filter {
            index, reminder in
            reminder.isOld() || reminder.isOutOfSync(given: self.pendingNotifications)
        }
        let indexesForOldAndOutOfSyncReminders = enumeratedOldAndOutOfSyncReminders.map{ index, reminder in index }
        let indexSetToRemove = IndexSet(indexesForOldAndOutOfSyncReminders)
        self.reminders.remove(at: indexSetToRemove)
        self.updatePendingNotificationsInView()
    }
}

struct RemindView_Previews: PreviewProvider {
    static var previews: some View {
        RemindView(reminders: Reminders.example)
    }
}
