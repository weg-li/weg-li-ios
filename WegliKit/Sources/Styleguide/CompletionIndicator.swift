// Created for weg-li in 2021.

import L10n
import SwiftUI

public struct CompletionIndicator: View {
  public init(isValid: Bool) {
    self.isValid = isValid
  }
  
  public var isValid: Bool
  
  public var body: some View {
    VStack {
      Image(systemName: isValid ? "checkmark.circle.fill" : "exclamationmark.circle.fill")
        .foregroundColor(isValid ? .green : .orange)
        .rotationEffect(.degrees(isValid ? 4 : 0))
        .accessibleAnimation(.easeOut(duration: 0.2), value: isValid)
    }
  }
}

struct CompletionIndicator_Previews: PreviewProvider {
  static var previews: some View {
    Group {
      CompletionIndicator(isValid: false)
      CompletionIndicator(isValid: true)
    }
    .font(.largeTitle)
  }
}
