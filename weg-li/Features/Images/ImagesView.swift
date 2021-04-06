// Created for weg-li in 2021.

import ComposableArchitecture
import SwiftUI

struct ImagesView: View {
    @ObservedObject private var viewStore: ViewStore<ImagesViewState, ImagesViewAction>

    init(store: Store<Report, ReportAction>) {
        viewStore = ViewStore(
            store.scope(
                state: \.images,
                action: { ReportAction.images($0) })
        )
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 20.0) {
            ScrollView(.horizontal) {
                ImageGrid(
                    images: viewStore.storedPhotos.compactMap { $0.asUIImage }) { index in
                        viewStore.send(.removePhoto(index: index))
                }
            }
            importButton
                .buttonStyle(EditButtonStyle())
        }
        .sheet(
            isPresented: viewStore.binding(
                get: \.showImagePicker,
                send: { ImagesViewAction.setShowImagePicker($0) }),
            content: {
                ImagePicker(
                    isPresented: viewStore.binding(
                        get: \.showImagePicker,
                        send: { ImagesViewAction.setShowImagePicker($0) }),
                    imagePickerHandler: { image, coordinate in
                        viewStore.send(.addPhoto(image))
                        viewStore.send(.setResolvedCoordinate(coordinate))
                    })
            })
    }

    private var importButton: some View {
        Button(action: {
            viewStore.send(.setShowImagePicker(true))
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
                initialState: .init(
                    images: .init(),
                    contact: ContactState.empty,
                    date: Date.init,
                    location: LocationViewState(storedPhotos: [])
                ),
                reducer: .empty,
                environment: ())
        )
    }
}
