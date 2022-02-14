// Created for weg-li in 2021.

import L10n
import SwiftUI

public struct DiscardButton: View {
  public init(action: @escaping () -> Void) {
    self.action = action
  }
  
  public let action: () -> Void
  
  public var body: some View {
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
