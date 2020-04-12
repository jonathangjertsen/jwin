import SwiftUI

struct RemindView: View {
    @ObservedObject var reminders: Reminders
    @ObservedObject var newReminder = Reminder.empty()
    
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
                            
                            /// Push the two pieces apart
                            Spacer()
                            
                            /// Show the date on the right
                            Text(DateFormatter.reminderFormat.string(
                                from: reminder.time
                            ))
                                .font(.caption)
                        }
                    }
                    /// Allow for reminders to be deleted
                    .onDelete(perform: { self.reminders.remove(at: $0 )})
                }
                
                /// Push the "new reminder" form downwards
                Spacer()
                
                /// Form for adding a new reminder
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
                        Button(action: { self.reminders.add(self.newReminder.transfer()) }) {
                            HStack {
                                Spacer()
                                Text("Create")
                                Spacer()
                            }
                        }
                    }
                }
            }
            .navigationBarTitle("Reminders")
        }
    }
}

struct RemindView_Previews: PreviewProvider {
    static var previews: some View {
        RemindView(reminders: Reminders.example)
    }
}
