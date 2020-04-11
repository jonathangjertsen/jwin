/*
 Row for a list
 */
import SwiftUI

struct ListRow: View {
    var list: JList
    
    var body: some View {
        NavigationLink(destination: ListOfItems(list: self.list)) {
            HStack {
                Text(self.list.name).padding().font(.headline)
                Spacer()
            }
        }
    }
}

struct ListRow_Previews: PreviewProvider {
    static var previews: some View {
        ListRow(list: JList.example)
    }
}
