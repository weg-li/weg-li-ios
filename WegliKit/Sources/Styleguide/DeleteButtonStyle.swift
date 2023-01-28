import Foundation
import SwiftUI

public struct DeleteButtonStyle: ButtonStyle {
  public init() {}
  
  public func makeBody(configuration: Configuration) -> some View {
    configuration.label
      .frame(maxWidth: .infinity)
      .padding()
      .foregroundColor(.red)
      .background(configuration.isPressed ? Color.red.opacity(0.2) : .clear)
      .clipShape(RoundedRectangle(cornerRadius: 16))
      .overlay(
        RoundedRectangle(cornerRadius: 16)
          .stroke(.red, lineWidth: 2)
      )
  }
}

public extension ButtonStyle where Self == DeleteButtonStyle {
  static var delete: Self {
    DeleteButtonStyle()
  }
}

struct DeleteButtonView_Previews: PreviewProvider {
  static var previews: some View {
    VStack {
      Button("This is a test") { }
        .buttonStyle(.delete)
    }
  }
}
