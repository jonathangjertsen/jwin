//
//  WideButton.swift
//  jwin
//
//  Created by jwin on 11/04/2020.
//  Copyright © 2020 jwin. All rights reserved.
//

import SwiftUI

struct WideButton: View {
    var text: String
    var color: Color
    var textColor: Color
    var action: () -> ()
    
    var body: some View {
        Button(action: self.action) {
            Spacer()
            Text(self.text)
                .padding()
            Spacer()
        }
            .padding()
            .background(self.color)
            .foregroundColor(self.textColor)
    }
}

struct WideButton_Previews: PreviewProvider {
    static var previews: some View {
        WideButton(text: "Click here!", color: .green, textColor: .white) {
            print("Tapped")
        }
    }
}
