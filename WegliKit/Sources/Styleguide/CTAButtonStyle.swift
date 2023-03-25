import SwiftUI

public struct CTAButtonStyle: ButtonStyle {
  public init() {}
  
  public func makeBody(configuration: Configuration) -> some View {
    configuration.label
      .font(.body.weight(.semibold))
      .padding()
      .foregroundColor(.white)
      .background(Color.wegliBlue)
      .clipShape(RoundedRectangle(cornerRadius: 10))
  }
}
