// Created for weg-li in 2021.

import ComposableArchitecture
import SwiftUI

struct ImageGrid: View {
    let store: Store<ImagesViewState, ImagesViewAction>
    @ObservedObject private var viewStore: ViewStore<ImagesViewState, ImagesViewAction>

    internal init(store: Store<ImagesViewState, ImagesViewAction>) {
        self.store = store
        viewStore = ViewStore(store)
    }

    private let gridItemLayout = [
        GridItem(.flexible(minimum: 50, maximum: .infinity)),
        GridItem(.flexible(minimum: 50, maximum: .infinity)),
        GridItem(.flexible(minimum: 50, maximum: .infinity))
    ]

    var body: some View {
        LazyVGrid(columns: gridItemLayout, spacing: 12) {
            ForEachStore(
                store.scope(
                    state: \.imageStates,
                    action: ImagesViewAction.image(id:action:)
                ),
                content: ImageView.init(store:)
            )
        }
    }
}

struct ImageGrid_Previews: PreviewProvider {
    static var previews: some View {
        ImageGrid(
            store: Store<ImagesViewState, ImagesViewAction>(
                initialState: .init(
                    showImagePicker: false,
                    storedPhotos: [
                        StorableImage(uiImage: UIImage(systemName: "book")!)!,
                        StorableImage(uiImage: UIImage(systemName: "book")!)!,
                        StorableImage(uiImage: UIImage(systemName: "book")!)!
                    ],
                    resolvedLocation: .zero
                ),
                reducer: .empty,
                environment: ImageEnvironment()
            )
        )
    }
}
