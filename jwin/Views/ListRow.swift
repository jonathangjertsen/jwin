import SwiftUI

/// A row in the list of lists representing an individual list.
/// Links to the detail view for the list.
struct ListRow: View {
    var list: JList
    
    var body: some View {
        /// Link to the detail view for the list
        NavigationLink(destination: ListOfItems(list: self.list)) {
            /// HStack with a spacer at the end allows for left-alignment
            HStack {
                /// Show the list in headline font
                Text(self.list.name)
                    .padding()
                    .font(.headline)

                /// Left-aligns the text
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
