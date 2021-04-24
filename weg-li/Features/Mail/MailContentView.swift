// Created for weg-li in 2021.

import ComposableArchitecture
import ComposableCoreLocation
import MessageUI
import SwiftUI

struct MailContentView: View {
    struct ViewState: Equatable {
        let districtName: String?
        let isSubmitButtonDisabled: Bool
        let isMailComposerPresented: Bool

        let isImagesValid: Bool
        let isLocationValid: Bool
        let isDescriptionValid: Bool
        let isContactValid: Bool

        init(state: Report) {
            districtName = state.district?.name
            isImagesValid = state.images.isValid
            isLocationValid = state.location.resolvedAddress.isValid
            isDescriptionValid = state.description.isValid
            isContactValid = state.contact.isValid

            let isValid = state.images.isValid
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
                action: ReportAction.mail
            )
        )
    }

    var body: some View {
        VStack(spacing: 6) {
            SubmitButton(
                state: .readyToSubmit(district: viewStore.districtName),
                disabled: viewStore.isSubmitButtonDisabled
            ) {
                viewStore.send(.submitButtonTapped)
            }
            .disabled(viewStore.isSubmitButtonDisabled)
            VStack(spacing: 8) {
                if !MFMailComposeViewController.canSendMail() {
                    Text(L10n.Mail.deviceErrorCopy)
                }
                if viewStore.isSubmitButtonDisabled {
                    VStack(spacing: 8) {
                        Text(L10n.Mail.readyToSubmitErrorCopy)
                            .fontWeight(.semibold)
                        VStack(spacing: 4) {
                            if !viewStore.isImagesValid {
                                Text(L10n.Report.Error.images)
                            }
                            if !viewStore.isLocationValid {
                                Text(L10n.Report.Error.location.asBulletPoint)
                            }
                            if !viewStore.isDescriptionValid {
                                Text(L10n.Report.Error.description.asBulletPoint)
                            }
                            if !viewStore.isContactValid {
                                Text(L10n.Report.Error.contact.asBulletPoint)
                            }
                        }
                    }
                }
            }
            .foregroundColor(.red)
            .font(.callout)
            .multilineTextAlignment(.center)
        }
        .sheet(isPresented: viewStore.binding(
            get: \.isMailComposerPresented,
            send: MailViewAction.presentMailContentView
        )) {
            MailView(store: store)
        }
    }
}

private extension String {
    var asBulletPoint: Self {
        "\u{2022} \(self)"
    }
}

#if DEBUG
    struct MailContentView_Previews: PreviewProvider {
        static var previews: some View {
            MailContentView(
                store: .init(
                    initialState: .init(
                        images: .init(),
                        contact: .preview,
                        date: Date.init
                    ),
                    reducer: reportReducer,
                    environment: ReportEnvironment(
                        mainQueue: .failing,
                        locationManager: .live,
                        placeService: .noop,
                        regulatoryOfficeMapper: .live()
                    )
                )
            )
        }
    }
#endif
