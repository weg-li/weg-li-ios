// Created for weg-li in 2021.

import ComposableArchitecture
import ContactFeature
import L10n
import SharedModels
import Styleguide
import SwiftUI

public struct ContactWidget: View {
  public struct ViewState: Equatable {
    let isResetButtonDisabled: Bool
    let contact: Contact
    let showEditScreen: Bool
    
    init(state: Report) {
      self.isResetButtonDisabled = state.contactState == .empty
      self.contact = state.contactState.contact
      self.showEditScreen = state.showEditContact
    }
  }
  
  public let store: Store<Report, ReportAction>
  @ObservedObject private var viewStore: ViewStore<ViewState, ReportAction>
  
  public init(store: Store<Report, ReportAction>) {
    self.store = store
    viewStore = ViewStore(store.scope(state: ViewState.init))
  }
  
  public var body: some View {
    VStack(alignment: .leading, spacing: 10) {
      row(callout: L10n.Contact.Row.nameCopy, content: "\(viewStore.contact.firstName) \(viewStore.contact.name)")
      row(callout: L10n.Contact.Row.streetCopy, content: viewStore.contact.address.street)
      row(callout: L10n.Contact.Row.cityCopy, content: "\(viewStore.contact.address.postalCode) \(viewStore.contact.address.city)")
      if !viewStore.contact.phone.isEmpty {
        row(callout: L10n.Contact.Row.phoneCopy, content: viewStore.contact.phone)
      }
      if !viewStore.contact.dateOfBirth.isEmpty {
        row(callout: L10n.Contact.Row.dateOfBirth, content: viewStore.contact.dateOfBirth)
      }
      if !viewStore.contact.address.addition.isEmpty {
        row(callout: L10n.Contact.Row.addressAddition, content: viewStore.contact.address.addition)
      }
      VStack(spacing: 8.0) {
        Button(
          action: { viewStore.send(.setShowEditContact(true)) },
          label: {
            HStack {
              Image(systemName: "pencil")
              Text(L10n.Contact.editButtonCopy)
            }
            .frame(maxWidth: .infinity)
          }
        )
          .buttonStyle(EditButtonStyle())
          .padding(.top)
        Text(L10n.Contact.reportHintCopy)
          .font(.footnote)
          .foregroundColor(.gray)
      }
      .fixedSize(horizontal: false, vertical: true)
    }
    .contentShape(Rectangle())
    .onTapGesture {
      viewStore.send(.setShowEditContact(true))
    }
    .sheet(
      isPresented: viewStore.binding(
        get: \.showEditScreen,
        send: ReportAction.setShowEditContact
      ), content: {
        NavigationView {
          ContactView(
            store: store.scope(
              state: { $0.contactState },
              action: ReportAction.contact
            )
          )
            .navigationBarItems(
              leading: Button(
                action: { viewStore.send(.setShowEditContact(false)) },
                label: { Text(L10n.Button.close) }
              ),
              trailing: resetButton
            )
        }
      }
    )
  }
  
  private var resetButton: some View {
    Button(
      action: { viewStore.send(.contact(.resetContactDataButtonTapped)) },
      label: {
        Image(systemName: "arrow.counterclockwise")
          .foregroundColor(viewStore.isResetButtonDisabled ? Color.red.opacity(0.6) : .red)
          .accessibilityHidden(true)
      }
    )
      .disabled(viewStore.isResetButtonDisabled)
      .accessibility(label: Text(L10n.Report.Alert.reset))
  }
  
  private func row(callout: String, content: String) -> some View {
    HStack {
      Text(callout)
        .foregroundColor(Color(.secondaryLabel))
        .font(.callout)
      Spacer()
      Text(content)
        .foregroundColor(Color(.label))
        .font(.body)
    }
  }
}

struct PersonalDataWidget_Previews: PreviewProvider {
  static var previews: some View {
    ContactWidget(
      store: .init(
        initialState: .preview,
        reducer: .empty,
        environment: ()
      )
    )
  }
}
