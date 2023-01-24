import SwiftUI

public struct SectionHeader: View {
  let text: String

  public init(text: String) {
    self.text = text
  }
  
  public var body: some View {
    Text(text)
      .font(.title3)
      .fontWeight(.semibold)
  }
}
