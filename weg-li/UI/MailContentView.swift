//
//  MailContentView.swift
//  weg-li
//
//  Created by Malte Bünz on 15.06.20.
//  Copyright © 2020 Stefan Trauth. All rights reserved.
//

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
            self.districtName = state.district?.name ?? ""
            self.isSubmitButtonDisabled = state.images.storedPhotos.isEmpty
                && !state.contact.isValid
                && !state.isDescriptionValid
                && !state.location.resolvedAddress.isValid
                && !MFMailComposeViewController.canSendMail()
            self.isMailComposerPresented = state.mail.isShowing
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
                state: .readyToSubmit(ordnungsamt: viewStore.districtName),
                disabled: viewStore.isSubmitButtonDisabled
            ) {
                viewStore.send(.setIsPresented(true))
            }
            .disabled(viewStore.isSubmitButtonDisabled)
            VStack(spacing: 8) {
                if !MFMailComposeViewController.canSendMail() {
                    Text("Auf diesem Gerät können leider keine E-Mails versendet werden!")
                }
                if viewStore.isSubmitButtonDisabled {
                    Text("Gib alle nötigen Daten an um die Anzeige zu versenden")
                        .fontWeight(.semibold)
                }
            }
            .foregroundColor(.red)
            .font(.callout)
            .multilineTextAlignment(.center)
        }
        .sheet(isPresented: viewStore.binding(
            get: \.isMailComposerPresented,
            send: { MailViewAction.setIsPresented($0) }
        )) {
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
                    contact: .preview
                ),
                reducer: reportReducer,
                environment: ReportEnvironment(
                    locationManager: LocationManager.unimplemented(),
                    placeService: PlacesServiceImplementation()
                )
            )
        )
    }
}
