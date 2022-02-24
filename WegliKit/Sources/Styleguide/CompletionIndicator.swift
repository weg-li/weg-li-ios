// Created for weg-li in 2021.

import L10n
import SwiftUI

public struct CompletionIndicator: View {
  public init(isValid: Bool) {
    self.isValid = isValid
  }
  
  public var isValid: Bool
  
  public var body: some View {
    let a11yLabel = isValid ? L10n.Widget.A11y.CompletionIndicatorLabel.isValid : L10n.Widget.A11y.CompletionIndicatorLabel.isNotValid
    return VStack {
      Image(systemName: isValid ? "checkmark.circle.fill" : "exclamationmark.circle.fill")
        .foregroundColor(isValid ? .green : .orange)
        .rotationEffect(.degrees(isValid ? 4 : 0))
        .animation(.easeOut(duration: 0.2), value: isValid)
        .accessibility(label: Text(a11yLabel))
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
