//
//  EditButtonStyle.swift
//  weg-li
//
//  Created by Malte Bünz on 15.06.20.
//  Copyright © 2020 Stefan Trauth. All rights reserved.
//

import SwiftUI

struct EditButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding()
            .background(Color(.tertiarySystemFill))
            .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}
