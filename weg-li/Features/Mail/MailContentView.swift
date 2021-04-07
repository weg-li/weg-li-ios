// Created for weg-li in 2021.

import ComposableArchitecture
import ComposableCoreLocation
import MessageUI
import SwiftUI

struct MailContentView: View {
    struct ViewState: Equatable {
        let districtName: String
        let isSubmitButtonDisabled: Bool
        let isMailComposerPresented: Bool

        init(state: Report) {
            districtName = state.district?.name ?? ""
            let isValid = !state.images.storedPhotos.isEmpty
                && state.contact.isValid
                && state.description.isValid
                && state.location.resolvedAddress.isValid
            isSubmitButtonDisabled = !isValid
            isMailComposerPresented = state.mail.isPresentingMailContent
        }
    }

    @ObservedObject private var viewStore: ViewStore<ViewState, MailViewAction>
    let store: Store<Report, ReportAction>

    init(store: Store<Report, ReportAction>) {
        self.store = store
        viewStore = ViewStore(
            store.scope(
                state: ViewState.init,
                action: ReportAction.mail)
        )
    }

    var body: some View {
        VStack(spacing: 6) {
            SubmitButton(
                state: .readyToSubmit(ordnungsamt: viewStore.districtName),
                disabled: viewStore.isSubmitButtonDisabled) {
                    viewStore.send(.submitButtonTapped)
            }
            .disabled(viewStore.isSubmitButtonDisabled)
            VStack(spacing: 8) {
                if !MFMailComposeViewController.canSendMail() {
                    Text(L10n.Mail.deviceErrorCopy)
                }
                if viewStore.isSubmitButtonDisabled {
                    Text(L10n.Mail.readyToSubmitErrorCopy)
                        .fontWeight(.semibold)
                }
            }
            .foregroundColor(.red)
            .font(.callout)
            .multilineTextAlignment(.center)
        }
        .sheet(isPresented: viewStore.binding(
            get: \.isMailComposerPresented,
            send: MailViewAction.presentMailContentView)) {
                MailView(store: store)
        }
    }
}

struct MailContentView_Previews: PreviewProvider {
    static var previews: some View {
        MailContentView(
            store: .init(
                initialState: .init(
                    images: .init(),
                    contact: .preview,
                    date: Date.init),
                reducer: reportReducer,
                environment: ReportEnvironment(
                    locationManager: .live,
                    placeService: PlacesServiceImplementation(),
                    regulatoryOfficeMapper: RegulatoryOfficeMapper(districtsRepo: DistrictRepository())))
        )
    }
}
