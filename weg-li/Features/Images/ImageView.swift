// Created for weg-li in 2021.

import ComposableArchitecture
import SwiftUI

struct ImageView: View {
    let store: Store<ImageState, ImageAction>
    @ObservedObject private var viewStore: ViewStore<ImageState, ImageAction>

    init(store: Store<ImageState, ImageAction>) {
        self.store = store
        viewStore = ViewStore(store)
    }

    var body: some View {
        Image(uiImage: viewStore.image.asUIImage!)
            .gridModifier
            .padding(4)
            .overlay(deleteButton, alignment: .center)
    }

    private var deleteButton: some View {
        Button(
            action: { viewStore.send(.removePhoto) },
            label: { Image(systemName: "trash") }
        )
        .buttonStyle(DeleteButtonStyle())
        .padding(4)
    }
}

struct DeleteButtonStyle: ButtonStyle {
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .padding(20)
            .foregroundColor(.red)
            .background(configuration.isPressed ? Color(.systemGray6).opacity(0.3) : Color(.systemGray3).opacity(0.7))
            .animation(.easeOut)
            .clipShape(Circle())
    }
}

private extension Image {
    var gridModifier: some View {
        self
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(
                minWidth: 50,
                maxWidth: .infinity/*@END_MENU_TOKEN@*/,
                minHeight: 100,
                maxHeight: 100
            )
            .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}

struct ImageView_Previews: PreviewProvider {
    static var previews: some View {
        ImageView(
            store: Store<ImageState, ImageAction>(
                initialState: .init(
                    id: .init(),
                    image: StorableImage(uiImage: UIImage(systemName: "pencil")!)!
                ),
                reducer: .empty,
                environment: ImageEnvironment()
            )
        )
    }
}
