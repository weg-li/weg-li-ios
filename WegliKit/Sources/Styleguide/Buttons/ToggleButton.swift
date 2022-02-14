// Created for weg-li in 2021.

import SwiftUI

public struct ToggleButton: View {
  public init(isOn: Binding<Bool>) {
    self._isOn = isOn
  }
  
  @Binding private(set) var isOn: Bool
  
  public var body: some View {
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
    .accessibilityValue(isOn ? "on" : "off")
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
