// Created for weg-li in 2021.

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
            .background(Color(.tertiarySystemFill))
            .clipShape(RoundedRectangle(cornerRadius: 10))
        }
    }
}

struct DiscardButton_Previews: PreviewProvider {
    static var previews: some View {
        DiscardButton {}
    }
}
