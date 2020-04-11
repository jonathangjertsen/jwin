/*
 List of lists
 
 TODOS:
    1. Add new list
 */
import SwiftUI

struct ListOfListsView: View {
    @ObservedObject var appState: AppState

    var body: some View {
        NavigationView {
            List {
                ForEach(self.appState.lists) {
                    list in
                    ListRow(list: list)
                }
                .onDelete(perform: removeRows)
                .onMove(perform: moveRows)
                
                HStack {
                    Spacer()
                    Button(action: self.addList) {
                        Text("New list")
                    }
                    Spacer()
                }
            }
            .navigationBarTitle("Lists")
            .navigationBarItems(trailing: EditButton())
        }
    }
    
    func addList() {
        self.appState.addList()
    }

    func removeRows(at offsets: IndexSet) {
        self.appState.removeLists(at: offsets)
    }

    func moveRows(from offsets: IndexSet, to destination: Int) {
        self.appState.moveLists(from: offsets, to: destination)
    }
}

struct ListOfListsView_Previews: PreviewProvider {
    static let appState = AppState.loadDemo()
    static var previews: some View {
        ListOfListsView(appState: appState)
    }
}
