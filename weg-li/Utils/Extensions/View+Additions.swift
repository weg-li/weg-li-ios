// Created for weg-li in 2021.

import SwiftUI

extension Image {
    func iconModifier() -> some View {
        renderingMode(.template)
            .resizable()
            .frame(width: 24, height: 24)
    }
}
