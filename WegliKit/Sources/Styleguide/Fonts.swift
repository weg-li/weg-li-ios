import SwiftUI

public enum FontName: String {
  case nummernschild = "GL-Nummernschild-Mtl"
}

public extension Font {
  static func custom(_ name: FontName, size: CGFloat) -> Self {
    .custom(name.rawValue, size: size)
  }
}

public extension View {
  func adaptiveFont(
    _ name: FontName,
    size: CGFloat,
    configure: @escaping (Font) -> Font = { $0 }
  ) -> some View {
    modifier(AdaptiveFont(name: name.rawValue, size: size, configure: configure))
  }
}

private struct AdaptiveFont: ViewModifier {
  @Environment(\.adaptiveSize) var adaptiveSize

  let name: String
  let size: CGFloat
  let configure: (Font) -> Font

  func body(content: Content) -> some View {
    content.font(configure(.custom(name, size: size + adaptiveSize.padding)))
  }
}

#if DEBUG
struct Font_Previews: PreviewProvider {
  static var previews: some View {
    registerFonts()

    return VStack(alignment: .leading, spacing: 12) {
      ForEach(
        [10, 12, 14, 16, 18, 20, 24, 32, 60].reversed(),
        id: \.self
      ) { fontSize in
        Text("Today’s daily challenge")
          .adaptiveFont(.nummernschild, size: CGFloat(fontSize))
      }
    }
  }
}
#endif
