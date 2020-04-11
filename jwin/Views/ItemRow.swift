/*
 Row for an individual item
 */
import SwiftUI

struct ItemRow: View {
    @ObservedObject var item: JListItem
    
    var body: some View {
        HStack {
            TextField("Text", text: $item.text).padding()
                .foregroundColor(item.active ? .primary : .secondary)
            Spacer()
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
