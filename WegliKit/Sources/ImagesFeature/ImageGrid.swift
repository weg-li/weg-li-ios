// Created for weg-li in 2021.

import ComposableArchitecture
import SharedModels
import SwiftUI

public struct ImageGrid: View {
  let store: Store<ImagesViewState, ImagesViewAction>
  @ObservedObject var viewStore: ViewStore<ImagesViewState, ImagesViewAction>
  
  public init(store: Store<ImagesViewState, ImagesViewAction>) {
    self.store = store
    viewStore = ViewStore(store)
  }
  
  let gridItemLayout = [
    GridItem(.flexible(minimum: 50, maximum: .infinity)),
    GridItem(.flexible(minimum: 50, maximum: .infinity)),
    GridItem(.flexible(minimum: 50, maximum: .infinity))
  ]
  
  public var body: some View {
    LazyVGrid(columns: gridItemLayout, spacing: 12) {
      ForEachStore(
        store.scope(
          state: \.imageStates,
          action: ImagesViewAction.image
        ),
        content: ImageView.init
      )
    }
    .transition(.opacity.combined(with: .move(edge: .bottom)))
  }
}

struct ImageGrid_Previews: PreviewProvider {
  static var previews: some View {
    ImageGrid(
      store: Store<ImagesViewState, ImagesViewAction>(
        initialState: .init(
          showImagePicker: false,
          storedPhotos: [
            // swiftlint:disable force_unwrapping
            StorableImage(uiImage: UIImage(systemName: "book")!)!,
            StorableImage(uiImage: UIImage(systemName: "book")!)!,
            StorableImage(uiImage: UIImage(systemName: "book")!)!
            // swiftlint:enable force_unwrapping
          ],
          coordinateFromImagePicker: .zero
        ),
        reducer: .empty,
        environment: ImageEnvironment()
      )
    )
  }
}
