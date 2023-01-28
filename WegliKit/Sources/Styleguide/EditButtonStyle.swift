// Created for weg-li in 2021.

import SwiftUI

public struct EditButtonStyle: ButtonStyle {
  public init() {}
  
  public func makeBody(configuration: Configuration) -> some View {
    configuration.label
      .padding()
      .foregroundColor(Color(.label))
      .background(Color(.tertiarySystemFill))
      .clipShape(RoundedRectangle(cornerRadius: 10))
  }
}

public extension ButtonStyle where Self == EditButtonStyle {
  static func edit() -> Self {
    EditButtonStyle()
  }
}

struct SwiftUIView_Previews: PreviewProvider {
  static var previews: some View {
    VStack {
      Button("This is a test") { }
        .buttonStyle(.edit())
      
      Button("This is a test") { }
        .buttonStyle(DeleteButtonStyle())
    }
  }
}
