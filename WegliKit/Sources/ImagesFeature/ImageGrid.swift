// Created for weg-li in 2021.

import ComposableArchitecture
import SharedModels
import SwiftUI

public struct ImageGridView: View {
  public typealias S = ImagesViewDomain.State
  public typealias A = ImagesViewDomain.Action
  
  let store: StoreOf<ImagesViewDomain>
  @ObservedObject var viewStore: ViewStoreOf<ImagesViewDomain>
  
  public init(store: StoreOf<ImagesViewDomain>) {
    self.store = store
    self.viewStore = ViewStore(store, observe: { $0 })
  }

  public var body: some View {
    ImageGrid {
      ForEachStore(
        store.scope(state: \.imageStates, action: A.image),
        content: ImageView.init
      )
    }
  }
}

public struct ImageGrid<Content: View>: View {
  let content: Content
  
  public init(@ViewBuilder _ content: () -> Content) {
    self.content = content()
  }
  
  let gridItemLayout = [
    GridItem(.flexible(minimum: 50, maximum: .infinity)),
    GridItem(.flexible(minimum: 50, maximum: .infinity)),
    GridItem(.flexible(minimum: 50, maximum: .infinity))
  ]
  
  public var body: some View {
    LazyVGrid(columns: gridItemLayout, spacing: .grid(2)) {
      content
    }
    .transition(.opacity.combined(with: .move(edge: .bottom)))
  }
}

struct ImageGrid_Previews: PreviewProvider {
  static var previews: some View {
    ImageGridView(
      store: Store(
        initialState: .init(
          showImagePicker: false,
          storedPhotos: [
            // swiftlint:disable force_unwrapping
            PickerImageResult(uiImage: UIImage(systemName: "book")!)!,
            PickerImageResult(uiImage: UIImage(systemName: "book")!)!,
            PickerImageResult(uiImage: UIImage(systemName: "book")!)!
            // swiftlint:enable force_unwrapping
          ],
          coordinateFromImagePicker: .zero
        ),
        reducer: { ImagesViewDomain() }
      )
    )
  }
}
