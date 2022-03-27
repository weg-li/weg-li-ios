// Created for weg-li in 2021.

import ComposableArchitecture
import SharedModels
import Styleguide
import SwiftUI

public struct ImageView: View {
  @Environment(\.accessibilityReduceMotion) var reduceMotion
  
  let store: Store<ImageState, ImageAction>
  @ObservedObject private var viewStore: ViewStore<ImageState, ImageAction>
  
  public init(store: Store<ImageState, ImageAction>) {
    self.store = store
    viewStore = ViewStore(store)
  }

  public var body: some View {
    if let url = viewStore.image.imageUrl {
      AsyncThumbnailView(url: url)
        .gridModifier
        .padding(4)
        .overlay(deleteButton, alignment: .center)
    } else if let image = viewStore.image.asUIImage {
      Image(uiImage: image)
        .gridModifier
        .padding(4)
        .overlay(deleteButton, alignment: .center)
    } else {
      ActivityIndicator(style: .medium)
    }
  }
  
  var deleteButton: some View {
    Button(
      action: { viewStore.send(.removePhoto, animation: .easeOut(duration: 0.2)) },
      label: { Image(systemName: "trash") }
    )
      .foregroundColor(.red)
      .buttonStyle(OnWidgetInteractionButtonStyle())
      .padding(4)
  }
}

private extension View {
  var gridModifier: some View {
    self
      .frame(
        minWidth: 50,
        maxWidth: .infinity,
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
          image: StorableImage(uiImage: UIImage(systemName: "pencil")!)! // swiftlint:disable:this force_unwrapping
        ),
        reducer: .empty,
        environment: ImageEnvironment()
      )
    )
  }
}
