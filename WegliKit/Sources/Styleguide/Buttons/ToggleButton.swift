// Created for weg-li in 2021.

import SwiftUI

public struct ToggleButton: View {
  public init(label: String, isOn: Binding<Bool>) {
    self._isOn = isOn
    self.label = label
  }
  
  @Binding private(set) var isOn: Bool
  let label: String
  
  public var body: some View {
    Button(action: { self.isOn.toggle() }) {
      HStack(alignment: .center, spacing: .grid(2)) {
        Text(label)
          .font(.body)
          .foregroundColor(.primary)
          .multilineTextAlignment(.leading)
        Spacer()
        if isOn {
          Image(systemName: "checkmark.circle.fill")
            .resizable()
            .frame(width: .grid(7), height: .grid(7))
            .foregroundColor(.green)
        } else {
          Image(systemName: "checkmark.circle.fill")
            .hidden()
            .frame(width: .grid(7), height: .grid(7))
            .overlay(
              Circle()
                .strokeBorder(Color.gray, lineWidth: 1)
            )
        }
      }
    }
    .accessibilityValue(isOn ? "on" : "off")
  }
}

struct ToggleButton_Previews: PreviewProvider {
  static var previews: some View {
    VStack {
      ToggleButton(label: "", isOn: .constant(false))
      ToggleButton(label: "", isOn: .constant(true))
    }
  }
}
