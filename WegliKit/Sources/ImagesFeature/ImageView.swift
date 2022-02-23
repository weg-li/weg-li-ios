// Created for weg-li in 2021.

import ComposableArchitecture
import SharedModels
import Styleguide
import SwiftUI

public struct ImageView: View {
  let store: Store<ImageState, ImageAction>
  @ObservedObject private var viewStore: ViewStore<ImageState, ImageAction>
  
  public init(store: Store<ImageState, ImageAction>) {
    self.store = store
    viewStore = ViewStore(store)
  }

  public var body: some View {
    if let url = viewStore.image.imageUrl {
      AsyncThumbnailView(url: url)
        .padding(4)
        .overlay(deleteButton, alignment: .center)
    } else {
      ActivityIndicator(style: .medium)
    }
  }
  
  var deleteButton: some View {
    Button(
      action: { viewStore.send(.removePhoto) },
      label: { Image(systemName: "trash") }
    )
      .foregroundColor(.red)
      .buttonStyle(OnWidgetInteractionButtonStyle())
      .padding(4)
  }
}

extension Image {
  var gridModifier: some View {
    self
      .resizable()
      .aspectRatio(contentMode: .fill)
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
