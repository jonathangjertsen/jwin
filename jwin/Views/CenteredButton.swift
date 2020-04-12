import SwiftUI

struct CenteredButton: View {
    var text: String
    var action: () -> ()
    var body: some View {
        HStack {
            Spacer()
            Button(action: self.action) {
                Text(self.text)
            }
            Spacer()
        }
    }
}

struct CenteredButton_Previews: PreviewProvider {
    static var previews: some View {
        CenteredButton(text: "Click me!") {
            print("Clicked")
        }
    }
}
