// Created for weg-li in 2021.

import ComposableArchitecture
import CoreLocation
import L10n
import SharedModels
import Styleguide
import SwiftUI

public struct ImagesView: View {
  let store: Store<ImagesViewState, ImagesViewAction>
  @ObservedObject private var viewStore: ViewStore<ImagesViewState, ImagesViewAction>
  
  public init(store: Store<ImagesViewState, ImagesViewAction>) {
    self.store = store
    viewStore = ViewStore(store)
  }
  
  public var body: some View {
    VStack(alignment: .leading, spacing: 20.0) {
      ImageGrid(store: store)
      importButton
        .buttonStyle(EditButtonStyle())
    }
    .alert(store.scope(state: { $0.alert }), dismiss: .dismissAlert)
    .sheet(
      isPresented: viewStore.binding(
        get: \.showImagePicker,
        send: ImagesViewAction.setShowImagePicker
      ),
      content: {
        ImagePicker(
          isPresented: viewStore.binding(
            get: \.showImagePicker,
            send: ImagesViewAction.setShowImagePicker
          ),
          pickerResult: viewStore.binding(
            get: \.storedPhotos,
            send: ImagesViewAction.addPhotos
          ),
          coordinate: viewStore.binding(
            get: \.coordinateFromImagePicker,
            send: ImagesViewAction.setResolvedCoordinate
          )
        )
      }
    )
  }
  
  private var importButton: some View {
    Button(action: {
      viewStore.send(.addPhotosButtonTapped)
    }) {
      HStack {
        Image(systemName: "photo.fill.on.rectangle.fill")
        Text(L10n.Photos.ImportButton.copy)
      }
      .frame(maxWidth: .infinity)
    }
  }
}

struct Images_Previews: PreviewProvider {
  static var previews: some View {
    ImagesView(
      store: .init(
        initialState: .init(),
        reducer: .empty,
        environment: ()
      )
    )
  }
}
