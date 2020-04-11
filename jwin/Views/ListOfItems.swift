/*
 List of items with title
 
 TODOS:
    1. Visual bug after reordering
    2. Some list elements hidden beneath keyboard
    3. Auto-focus on new element after creation
    4. Press enter to create new element
 */
import SwiftUI

struct ListOfItems: View {
    @ObservedObject var list: JList
    @State var showingActive: Bool = true
    
    var body: some View {
        List {
            ForEach(self.list.items.filter { showingActive || $0.active }) {
                item in
                ItemRow(item: item)
            }
            .onDelete(perform: self.removeRows)
            .onMove(perform: self.move)

            HStack {
                Spacer()
                Button(action: self.addRow) {
                    Text("New").padding()
                }
                Spacer()
            }
        }
        .navigationBarTitle(Text(self.list.name).font(.caption), displayMode: .inline)
        .navigationBarItems(trailing: HStack {
            EditButton()
            Toggle(isOn: $showingActive) {
                Text("All")
            }
        })
    }
    
    func addRow() {
        self.list.addEmpty()
    }
    
    func removeRows(at offsets: IndexSet) {
        self.list.remove(at: offsets)
    }
    
    func move(from source: IndexSet, to destination: Int) {
        self.list.move(from: source, to: destination)
    }
}

struct ListOfItems_Previews: PreviewProvider {
    static var previews: some View {
        ListOfItems(list: JList.example)
    }
}
