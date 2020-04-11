import SwiftUI

/**
View for the "lists" sub-app
*/
struct ListOfListsView: View {
    @ObservedObject var appState: AppState

    var body: some View {
        NavigationView {
            List {
                /// List of lists
                ForEach(self.appState.lists) {
                    list in
                    ListRow(list: list)
                }
                /// Allow for the lists to be deleted and moved
                .onDelete(perform: { self.appState.removeLists(at: $0)})
                .onMove(perform: { self.appState.moveLists(from: $0, to: $1) })
                
                /// Button to create a new list
                HStack {
                    Spacer()
                    Button(action: { self.appState.addList() }) {
                        Text("New list")
                    }
                    Spacer()
                }
            }

            /// Nav bar with edit button
            .navigationBarTitle("Lists")
            .navigationBarItems(trailing: EditButton())
        }
    }
}

struct ListOfListsView_Previews: PreviewProvider {
    static var previews: some View {
        ListOfListsView(appState: AppState.loadDemo())
    }
}
