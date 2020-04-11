import SwiftUI

/**
List of items with title

TODOS:
   1. Some list elements hidden beneath keyboard
   2. Auto-focus on new element after creation
   3. Press enter to create new element
*/
struct ListOfItems: View {
    @ObservedObject var list: JList
    @State var showingActive: Bool = true
    
    var body: some View {
        List {
            /// Show each of the items
            /// Filter out inactive item if requested
            ForEach(self.list.items.filter { showingActive || $0.active }) {
                item in
                ItemRow(item: item)
            }
            /// Allow each item to be deleted and moved
            .onDelete(perform:  { self.list.remove(at: $0) })
            .onMove(perform: { self.list.move(from: $0, to: $1) })

            /// Placeholder entry for adding a new item
            HStack {
                /// Leading spacer for center alignment
                Spacer()
                
                /// Button to press
                Button(action: { self.list.addEmpty() }) {
                    Text("New").padding()
                }
                
                /// Trailing spacer for center alignment
                Spacer()
            }
        }

        /// Navbar title, inline to prevent the link back to the main page from breaking the line
        .navigationBarTitle(
            Text(self.list.name),
            displayMode: .inline
        )

        /// Edit button and toggle for showing inactive items. A bit cramped.
        .navigationBarItems(trailing: HStack {
            EditButton()
            Toggle(isOn: $showingActive) {
                Text("All").font(.caption)
            }
        })
    }
}

struct ListOfItems_Previews: PreviewProvider {
    static var previews: some View {
        ListOfItems(list: JList.example)
    }
}
