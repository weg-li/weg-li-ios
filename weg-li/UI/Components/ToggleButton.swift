//
//  ToggleButton.swift
//  weg-li
//
//  Created by Malte Bünz on 15.06.20.
//  Copyright © 2020 Stefan Trauth. All rights reserved.
//

import SwiftUI

struct ToggleButton: View {
    @Binding private(set) var isOn: Bool
    
    var body: some View {
        Button(action: { self.isOn.toggle() }) {
            if isOn {
                Image(systemName: "checkmark.circle.fill")
                    .resizable()
                    .frame(width: 35, height: 35)
                    .foregroundColor(.green)
            } else {
                Image(systemName: "checkmark.circle.fill")
                    .hidden()
                    .frame(width: 35, height: 35)
                    .overlay(
                        Circle()
                            .strokeBorder(Color.gray, lineWidth: 1)
                )
            }
        }
    }
}

struct ToggleButton_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            ToggleButton(isOn: .constant(false))
            ToggleButton(isOn: .constant(true))
        }
    }
}
