//
//  DiscardButton.swift
//  weg-li
//
//  Created by Stefan Trauth on 08.10.19.
//  Copyright © 2019 Stefan Trauth. All rights reserved.
//

import SwiftUI

struct DiscardButton: View {
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: "trash")
                Text("Anzeige verwerfen")
            }
            .font(.subheadline)
            .foregroundColor(.red)
            .padding()
            .background(Color(.secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 10))
        }
    }
}

struct DiscardButton_Previews: PreviewProvider {
    static var previews: some View {
        DiscardButton {}
    }
}
