import SwiftUI

extension View {
    func eraseToAnyView() -> AnyView { AnyView(self) }
}

extension Image {
    func iconModifier() -> some View {
        renderingMode(.template)
            .resizable()
            .frame(width: 24, height: 24)
    }
}
