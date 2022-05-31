import SwiftUI

public struct HVStack<Content: View>: View {
  let useVStack: Bool
  let alignment: Alignment
  let spacing: CGFloat?
  let content: () -> Content
  
  public init(
    useVStack: Bool,
    alignment: Alignment = Alignment(horizontal: .leading, vertical: .center),
    spacing: CGFloat? = nil,
    @ViewBuilder content: @escaping () -> Content
  ) {
    self.useVStack = useVStack
    self.alignment = alignment
    self.spacing = spacing
    self.content = content
  }
  
  public var body: some View {
    if useVStack {
      VStack(alignment: alignment.horizontal, spacing: spacing, content: content)
    } else {
      HStack(alignment: alignment.vertical, spacing: spacing, content: content)
    }
  }
}
