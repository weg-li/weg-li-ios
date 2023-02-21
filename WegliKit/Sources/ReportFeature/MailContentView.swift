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
    
    init(state: ReportDomain.State) {
      self.districtName = state.district?.name
      self.isImagesValid = state.images.isValid
      self.isLocationValid = state.location.resolvedAddress.isValid
      self.isDescriptionValid = state.description.isValid
      self.isContactValid = state.contactState.contact.isValid
      
      self.isSubmitButtonDisabled = !state.isReportValid
      self.isMailComposerPresented = state.mail.isPresentingMailContent
    }
  }
  
  @ObservedObject private var viewStore: ViewStore<ViewState, ReportDomain.Action>
  private let store: StoreOf<ReportDomain>
  
  init(store: StoreOf<ReportDomain>) {
    self.store = store
    self.viewStore = ViewStore(store.scope(state: ViewState.init), observe: { $0 })
  }
  
  var body: some View {
    VStack(spacing: .grid(2)) {
      SubmitButton(
        state: .readyToSubmit(district: viewStore.districtName),
        disabled: viewStore.isSubmitButtonDisabled
      ) { viewStore.send(.mail(.submitButtonTapped)) }
        .accessibilityValue(viewStore.isSubmitButtonDisabled ? "deaktviert" : "aktiviert")
        .accessibilityHint(viewStore.isSubmitButtonDisabled ? L10n.Mail.readyToSubmitErrorCopy : "")
        .padding(.bottom, .grid(2))
        .disabled(viewStore.isSubmitButtonDisabled)
      
      VStack(spacing: .grid(2)) {
        if !MFMailComposeViewController.canSendMail() {
          Text(L10n.Mail.deviceErrorCopy)
        }
      }
      .accessibilityElement(children: .combine)
      .foregroundColor(.red)
      .font(.callout)
      .multilineTextAlignment(.center)
    }
    .sheet(isPresented: viewStore.binding(
      get: \.isMailComposerPresented,
      send: { ReportDomain.Action.mail(.presentMailContentView($0)) }
    )) {
      MailView(
        store: store.scope(
          state: \.mail,
          action: ReportDomain.Action.mail
        )
      )
    }
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
        reducer: ReportDomain()
      )
    )
  }
}
#endif
