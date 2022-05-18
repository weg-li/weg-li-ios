// Created for weg-li in 2021.

import ComposableArchitecture
import ComposableCoreLocation
import L10n
import MailFeature
import MessageUI
import Styleguide
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
    
    init(state: ReportState) {
      districtName = state.district?.name
      isImagesValid = state.images.isValid
      isLocationValid = state.location.resolvedAddress.isValid
      isDescriptionValid = state.description.isValid
      isContactValid = state.contactState.isValid
      
      let isValid = state.images.isValid
      && state.contactState.isValid
      && state.description.isValid
      && state.location.resolvedAddress.isValid
      isSubmitButtonDisabled = !isValid
      isMailComposerPresented = state.mail.isPresentingMailContent
    }
  }
  
  @ObservedObject private var viewStore: ViewStore<ViewState, ReportAction>
  let store: Store<ReportState, ReportAction>
  
  init(store: Store<ReportState, ReportAction>) {
    self.store = store
    viewStore = ViewStore(store.scope(state: ViewState.init))
  }
  
  var body: some View {
    VStack(spacing: .grid(2)) {
      SubmitButton(
        state: .readyToSubmit(district: viewStore.districtName),
        disabled: viewStore.isSubmitButtonDisabled
      ) {
        viewStore.send(.mail(.submitButtonTapped))
      }
      .accessibilityValue(viewStore.isSubmitButtonDisabled ? "deaktviert" : "aktiviert")
      .accessibilityHint(viewStore.isSubmitButtonDisabled ? L10n.Mail.readyToSubmitErrorCopy : "")
      .padding(.bottom, .grid(2))
      .disabled(viewStore.isSubmitButtonDisabled)
      VStack(spacing: .grid(2)) {
        if !MFMailComposeViewController.canSendMail() {
          Text(L10n.Mail.deviceErrorCopy)
        }
        if viewStore.isSubmitButtonDisabled {
          VStack(spacing: .grid(2)) {
            Text(L10n.Mail.readyToSubmitErrorCopy)
              .fontWeight(.semibold)
            VStack(spacing: .grid(1)) {
              if !viewStore.isImagesValid {
                Text(L10n.Report.Error.images.asBulletPoint)
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
      .accessibilityElement(children: .combine)
      .foregroundColor(.red)
      .font(.callout)
      .multilineTextAlignment(.center)
    }
    .sheet(isPresented: viewStore.binding(
      get: \.isMailComposerPresented,
      send: { ReportAction.mail(.presentMailContentView($0)) }
    )) {
      MailView(
        store: store.scope(
          state: \.mail,
          action: ReportAction.mail
        )
      )
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
          uuid: UUID.init,
          images: .init(),
          contactState: .preview,
          date: Date.init
        ),
        reducer: reportReducer,
        environment: ReportEnvironment(
          mainQueue: .failing,
          backgroundQueue: .failing,
          locationManager: .live,
          placeService: .noop,
          regulatoryOfficeMapper: .live(),
          fileClient: .noop,
          date: Date.init
        )
      )
    )
  }
}
#endif
