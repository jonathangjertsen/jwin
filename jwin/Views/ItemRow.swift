import SwiftUI

/// Row for an individual item in a list
struct ItemRow: View {
    @ObservedObject var item: JListItem
    
    var body: some View {
        HStack {
            /// Editable text field with grayed-out text if the item is inactive
            TextField(
                "(no text)",
                text: $item.text
            )
                .padding()
                .foregroundColor(
                    item.active
                        ? .primary
                        : .secondary
                )
        
            /// Move the text field to the left, the toggle to the right
            Spacer()
        
            /// Toggle to set whether the item should be active
            Toggle("Active", isOn: $item.active)
                .labelsHidden()
                .padding()
        }
    }
}

struct ItemRow_Previews: PreviewProvider {
    static var previews: some View {
        ItemRow(item: JListItem.example)
    }
}
