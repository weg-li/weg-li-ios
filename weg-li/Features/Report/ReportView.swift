//
//  ReportView.swift
//  weg-li
//
//  Created by Malte on 24.03.21.
//  Copyright © 2021 Martin Wilhelmi. All rights reserved.
//

import ComposableArchitecture
import SwiftUI

struct ReportForm: View {
    struct ViewState: Equatable {
        let isPhotosValid: Bool
        let isContactValid: Bool
        let isDescriptionValid: Bool
        let isLocationValid: Bool
        
        init(state: Report) {
            isPhotosValid = !state.images.storedPhotos.isEmpty
            isContactValid = state.contact.isValid
            isDescriptionValid = state.isDescriptionValid
            isLocationValid = state.location.resolvedAddress.isValid
        }
    }
    
    private let store: Store<Report, ReportAction>
    @ObservedObject private var viewStore: ViewStore<ViewState, ReportAction>
    
    init(store: Store<Report, ReportAction>) {
        self.store = store
        viewStore = ViewStore(store.scope(state: ViewState.init))
    }
        
    var body: some View {
        ScrollView {
            VStack {
                // Fotos
                Widget(
                    title: Text("Fotos"), // TODO: Replace with l18n
                    isCompleted: viewStore.isPhotosValid
                ) { ImagesView(store: store) }
                // Ort
                Widget(
                    title: Text("Ort"), // TODO: Replace with l18n
                    isCompleted: viewStore.isLocationValid) { LocationView(store: store) }
                // Beschreibung
                Widget(
                    title: Text("Beschreibung"), // TODO: Replace with l18n
                    isCompleted: viewStore.isDescriptionValid
                ) { DescriptionView(store: store) }
                // Kontaktdaten
                Widget(
                    title: Text("Kontaktdaten"), // TODO: Replace with l18n
                    isCompleted: viewStore.isContactValid
                ) { ContactWidget(store: store.scope(state: { $0.contact })) }
                MailContentView(store: store)
                    .padding()
            }
        }
        .padding(.bottom)
        .navigationBarTitle("Anzeige", displayMode: .inline)
    }
}

struct ReportForm_Previews: PreviewProvider {
    static var previews: some View {
        ReportForm(
            store: .init(
                initialState: .preview,
                reducer: .empty,
                environment: ()
            )
        )
//        .preferredColorScheme(.dark)
//        .environment(\.sizeCategory, .large)
    }
}
