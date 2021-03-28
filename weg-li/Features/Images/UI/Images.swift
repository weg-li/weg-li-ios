//
//  Images.swift
//  weg-li
//
//  Created by Stefan Trauth on 09.10.19.
//  Copyright © 2019 Stefan Trauth. All rights reserved.
//

import ComposableArchitecture
import SwiftUI


struct Images: View {
    struct ViewState: Equatable {
        let photos: [UIImage]
        
        init(state: Report) {
            self.photos = state.storedPhotos.compactMap { UIImage(data: $0.image)! }
        }
    }
    
    @ObservedObject private var viewStore: ViewStore<ViewState, ReportAction>
    
    init(store: Store<Report, ReportAction>) {
        viewStore = ViewStore(store.scope(state: ViewState.init))
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20.0) {
            ScrollView(.horizontal) {
                ImageGrid(
                    images: viewStore.photos) { index in
                        viewStore.send(.removePhoto(index: index))
                    }
            }
            ImagePickerButtons { image in
                viewStore.send(.addPhoto(image))
            }
            .buttonStyle(EditButtonStyle())
        }
    }
}

struct Images_Previews: PreviewProvider {
    static var previews: some View {
        Images(
            store: .init(
                initialState: .init(
                    contact: ContactState.empty,
                    location: LocationViewState()
                ),
                reducer: .empty,
                environment: ()
            )
        )
    }
}
