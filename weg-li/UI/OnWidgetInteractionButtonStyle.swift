// Created for weg-li in 2021.

import SwiftUI

struct OnWidgetInteractionButtonStyle: ButtonStyle {
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .padding(20)
            .background(configuration.isPressed ? Color(.systemGray6).opacity(0.3) : Color(.systemGray3).opacity(0.7))
            .animation(.easeOut)
            .clipShape(Circle())
    }
}

struct OnWidgetInteractionButtonStyle_Previews: PreviewProvider {
    static var previews: some View {
        Preview {
            Button(
                action: {}/*@END_MENU_TOKEN@*/,
                label: {
                    Image(systemName: "trash")
                }
            )
            .buttonStyle(OnWidgetInteractionButtonStyle())
        }
    }
}
