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
