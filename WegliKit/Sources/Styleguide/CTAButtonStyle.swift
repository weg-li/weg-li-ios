import SwiftUI

public struct CTAButtonStyle: ButtonStyle {
  public init() {}
  
  public func makeBody(configuration: Configuration) -> some View {
    configuration.label
      .padding()
      .foregroundColor(.white)
      .background(Color.wegliBlue)
      .clipShape(RoundedRectangle(cornerRadius: 10))
  }
}
