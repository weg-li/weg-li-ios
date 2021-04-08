// Created for weg-li in 2021.

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
            isDescriptionValid = state.description.isValid
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
                // Photos
                Widget(
                    title: Text(L10n.Photos.widgetTitle),
                    isCompleted: viewStore.isPhotosValid
                ) { ImagesView(store: store) }
                // Location
                Widget(
                    title: Text(L10n.Location.widgetTitle),
                    isCompleted: viewStore.isLocationValid
                ) { LocationView(store: store) }
                // Description
                Widget(
                    title: Text(L10n.Description.widgetTitle),
                    isCompleted: viewStore.isDescriptionValid
                ) { DescriptionView(store: store) }
                // Contact
                Widget(
                    title: Text(L10n.Report.Contact.widgetTitle),
                    isCompleted: viewStore.isContactValid
                ) { ContactWidget(store: store.scope(state: { $0.contact })) }
                MailContentView(store: store)
                    .padding()
            }
        }
        .padding(.bottom)
        .navigationBarTitle(L10n.Report.navigationBarTitle, displayMode: .inline)
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
