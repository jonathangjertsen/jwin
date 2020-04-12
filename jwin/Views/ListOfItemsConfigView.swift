import SwiftUI

/// A view for configuring a list
/// Just here so I can rename it, ideally it should be editable from the nav bar
struct ListOfItemsConfigView: View {
    @ObservedObject var list: JList
    var body: some View {
        Form {
            Section(header: Text("List name")) {
                TextField("(unnamed list)", text: $list.name)
            }
        }.navigationBarTitle("Configure \(list.name)")
    }
}

struct ListOfItemsConfigView_Previews: PreviewProvider {
    static var previews: some View {
        ListOfItemsConfigView(list: JList.example)
    }
}
