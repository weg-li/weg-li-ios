// Created for weg-li in 2021.

import ComposableArchitecture
import L10n
import SharedModels
import SwiftUI

public struct ContactView: View {
  let store: Store<ContactState, ContactAction>
  @ObservedObject private var viewStore: ViewStore<ContactState, ContactAction>
  
  public init(store: Store<ContactState, ContactAction>) {
    self.store = store
    viewStore = ViewStore(store)
  }
  
  public var body: some View {
    VStack {
      Form {
        Section(header: Text(L10n.Contact.Section.required)) {
          dataRow(
            type: .firstName,
            textFieldBinding: viewStore.binding(
              get: \.contact.firstName,
              send: ContactAction.firstNameChanged
            )
          )
          dataRow(
            type: .lastName,
            textFieldBinding: viewStore.binding(
              get: \.contact.name,
              send: ContactAction.lastNameChanged
            )
          )
          dataRow(
            type: .street,
            textFieldBinding: viewStore.binding(
              get: \.contact.address.street,
              send: ContactAction.streetChanged
            )
          )
          HStack {
            dataRow(
              type: .zipCode,
              textFieldBinding: viewStore.binding(
                get: \.contact.address.postalCode,
                send: ContactAction.zipCodeChanged
              )
            )
            dataRow(
              type: .town,
              textFieldBinding: viewStore.binding(
                get: \.contact.address.city,
                send: ContactAction.townChanged
              )
            )
          }
        }
        Section(header: Text(L10n.Contact.Section.optional)) {
          dataRow(
            type: .phone,
            textFieldBinding: viewStore.binding(
              get: \.contact.phone,
              send: ContactAction.phoneChanged
            )
          )
          dataRow(
            type: .dateOfBirth,
            textFieldBinding: viewStore.binding(
              get: \.contact.dateOfBirth,
              send: ContactAction.dateOfBirthChanged
            )
          )
          dataRow(
            type: .addressAddition,
            textFieldBinding: viewStore.binding(
              get: \.contact.address.addition,
              send: ContactAction.addressAdditionChanged
            )
          )
        }
        Section(header: Image(systemName: "info.circle").font(.body)) {
          VStack(spacing: 16) {
            Text(L10n.Contact.mailInfo)
              .multilineTextAlignment(.center)
            Text(L10n.Contact.isSavedInAppHintCopy)
              .multilineTextAlignment(.center)
          }
          .font(.callout)
        }
      }
    }
    .alert(store.scope(state: { $0.alert }), dismiss: .dismissAlert)
    .navigationBarTitle(L10n.Contact.widgetTitle, displayMode: .inline)
    .navigationBarItems(trailing: resetButton)
    .onDisappear { viewStore.send(.onDisappear) }
  }
  
  private var resetButton: some View {
    let isButtonDisabled = viewStore.state == .empty
    return Button(
      action: { viewStore.send(.resetContactDataButtonTapped) },
      label: {
        Text(L10n.Contact.Alert.reset)
          .foregroundColor(isButtonDisabled ? Color.red.opacity(0.6) : .red)
          .accessibility(hidden: true)
      }
    )
      .disabled(isButtonDisabled)
      .accessibility(label: Text(L10n.Report.Alert.reset))
  }
  
  private func dataRow(type: RowType, textFieldBinding: Binding<String>) -> some View {
    VStack(alignment: .leading) {
      HStack {
        Text(type.label)
          .font(.callout)
          .foregroundColor(Color(.secondaryLabel))
      }
      TextField(type.placeholder, text: textFieldBinding)
        .multilineTextAlignment(.leading)
        .keyboardType(type.keyboardType)
        .textFieldStyle(PlainTextFieldStyle())
        .textContentType(type.textContentType)
        .disableAutocorrection(true)
    }
  }
}

struct PersonalData_Previews: PreviewProvider {
  static var previews: some View {
    ContactView(
      store: .init(
        initialState: .preview,
        reducer: .empty,
        environment: ()
      )
    )
  }
}
