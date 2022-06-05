// Created for weg-li in 2021.

import SwiftUI

public struct OnWidgetInteractionButtonStyle: ButtonStyle {
  @Environment(\.accessibilityReduceTransparency) var reduceTransparency
  
  public init() {}
  
  public func makeBody(configuration: Self.Configuration) -> some View {
    configuration.label
      .padding(20)
      .background(
        configuration.isPressed
          ? (reduceTransparency ? Color(.systemGray6) : Color(.systemGray6).opacity(0.3))
          : (reduceTransparency ? Color(.systemGray3) : Color(.systemGray3).opacity(0.7))
      )
      .accessibleAnimation(.easeOut, value: configuration.isPressed)
      .clipShape(Circle())
  }
}

struct OnWidgetInteractionButtonStyle_Previews: PreviewProvider {
  static var previews: some View {
    Button(
      action: {},
      label: {
        Image(systemName: "trash")
      }
    )
    .buttonStyle(OnWidgetInteractionButtonStyle())
  }
}
