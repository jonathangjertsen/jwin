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
            Button(action: {
                self.item.active.toggle()
            }) {
                HStack {
                    ZStack {
                        Rectangle()
                            .stroke(Color.accentColor, lineWidth: 3)
                            .frame(width: 23, height: 23, alignment: .center)
                        
                        Rectangle()
                            .fill(self.item.active ? Color.clear : Color.accentColor)
                            .frame(width: 20, height: 20, alignment: .center)
                        .padding()
                    }
                }
            }
        }
    }
}

struct ItemRow_Previews: PreviewProvider {
    static var previews: some View {
        ItemRow(item: JListItem.example)
    }
}
