// Created for weg-li in 2021.

import ComposableArchitecture
import CoreLocation
import SwiftUI

struct ImagesView: View {
    struct ViewState: Equatable {
        let resolvedLocation: CLLocationCoordinate2D?
        let photos: [StorableImage?]
        let showImagePicker: Bool

        init(state: Report) {
            resolvedLocation = state.images.coordinateFromImagePicker
            photos = state.images.storedPhotos
            showImagePicker = state.images.showImagePicker
        }
    }

    let store: Store<Report, ReportAction>
    @ObservedObject private var viewStore: ViewStore<ViewState, ImagesViewAction>

    init(store: Store<Report, ReportAction>) {
        self.store = store
        viewStore = ViewStore(
            store.scope(
                state: ViewState.init,
                action: ReportAction.images
            )
        )
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 20.0) {
            ImageGrid(
                store: store.scope(
                    state: \.images,
                    action: ReportAction.images
                )
            )
            importButton
                .buttonStyle(EditButtonStyle())
        }
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
                        get: \.photos,
                        send: ImagesViewAction.addPhotos
                    ),
                    coordinate: viewStore.binding(
                        get: \.resolvedLocation,
                        send: ImagesViewAction.setResolvedCoordinate
                    )
                )
            }
        )
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
                    location: LocationViewState()
                ),
                reducer: .empty,
                environment: ()
            )
        )
    }
}
