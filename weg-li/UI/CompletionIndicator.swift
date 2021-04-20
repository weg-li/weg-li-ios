// Created for weg-li in 2021.

import SwiftUI

struct CompletionIndicator: View {
    var isValid: Bool

    var body: some View {
        let a11yLabel = isValid ? L10n.Widget.A11y.CompletionIndicatorLabel.isValid : L10n.Widget.A11y.CompletionIndicatorLabel.isNotValid
        return
            VStack {
                Image(systemName: isValid ? "checkmark.circle.fill" : "exclamationmark.circle.fill")
                    .foregroundColor(isValid ? .green : .orange)
                    .rotationEffect(.degrees(isValid ? 4 : 0))
                    .animation(.easeOut(duration: 0.2))
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
