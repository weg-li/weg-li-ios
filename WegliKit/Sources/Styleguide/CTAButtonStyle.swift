import SwiftUI

public struct CTAButtonStyle: ButtonStyle {
  public init() {}
  
  public func makeBody(configuration: Configuration) -> some View {
    configuration.label
      .font(.body.weight(.semibold))
      .padding()
      .foregroundColor(configuration.isPressed ? Color.white.opacity(0.7) : .white)
      .background(Color.wegliBlue)
      .clipShape(RoundedRectangle(cornerRadius: 10))
  }
}
