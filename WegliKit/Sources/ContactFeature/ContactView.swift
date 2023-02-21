// Created for weg-li in 2021.

import Combine
import ComposableArchitecture
import L10n
import SharedModels
import Styleguide
import SwiftUI

public struct ContactDetailsView: View {
  let store: Store<ContactDomain.State, ContactDomain.Action>
  @ObservedObject private var viewStore: ViewStore<ContactDomain.State, ContactDomain.Action>
  
  @FocusState private var focusedField: RowType?
  
  public init(store: Store<ContactDomain.State, ContactDomain.Action>) {
    self.store = store
    self.viewStore = ViewStore(store)
  }
  
  public var body: some View {
    VStack {
      Form {
        Section(header: Text(L10n.Contact.Section.required)) {
          dataRow(type: .firstName) {
            TextField(RowType.firstName.placeholder, text: viewStore.binding(\.$firstName))
              .multilineTextAlignment(.leading)
              .keyboardType(RowType.firstName.keyboardType)
              .textContentType(RowType.firstName.textContentType)
              .disableAutocorrection(true)
              .submitLabel(.next)
              .focused($focusedField, equals: .firstName)
          }
          dataRow(type: .lastName) {
            TextField(RowType.lastName.placeholder, text: viewStore.binding(\.$name))
              .multilineTextAlignment(.leading)
              .keyboardType(RowType.lastName.keyboardType)
              .textContentType(RowType.lastName.textContentType)
              .disableAutocorrection(true)
              .submitLabel(.next)
              .focused($focusedField, equals: .lastName)
          }
          dataRow(type: .street) {
            TextField(RowType.street.placeholder, text: viewStore.binding(\.$address.street))
              .multilineTextAlignment(.leading)
              .keyboardType(RowType.street.keyboardType)
              .textContentType(RowType.street.textContentType)
              .disableAutocorrection(true)
              .submitLabel(.next)
              .focused($focusedField, equals: .street)
          }
          HStack {
            dataRow(type: .zipCode) {
              TextField(RowType.zipCode.placeholder, text: viewStore.binding(\.$address.postalCode))
                .multilineTextAlignment(.leading)
                .keyboardType(RowType.zipCode.keyboardType)
                .textContentType(RowType.zipCode.textContentType)
                .disableAutocorrection(true)
                .submitLabel(.next)
                .focused($focusedField, equals: .zipCode)
            }
            dataRow(type: .city) {
              TextField(RowType.city.placeholder, text: viewStore.binding(\.$address.city))
                .multilineTextAlignment(.leading)
                .keyboardType(RowType.city.keyboardType)
                .textContentType(RowType.city.textContentType)
                .disableAutocorrection(true)
                .submitLabel(.next)
                .focused($focusedField, equals: .city)
            }
          }
        }
        Section(header: Text(L10n.Contact.Section.optional)) {
          dataRow(type: .phone) {
            TextField(RowType.phone.placeholder, text: viewStore.binding(\.$phone))
              .multilineTextAlignment(.leading)
              .keyboardType(RowType.phone.keyboardType)
              .textContentType(RowType.phone.textContentType)
              .disableAutocorrection(true)
              .submitLabel(.next)
              .focused($focusedField, equals: .phone)
          }
          dataRow(type: .dateOfBirth) {
            TextField(RowType.dateOfBirth.placeholder, text: viewStore.binding(\.$dateOfBirth))
              .multilineTextAlignment(.leading)
              .keyboardType(RowType.dateOfBirth.keyboardType)
              .textContentType(RowType.dateOfBirth.textContentType)
              .disableAutocorrection(true)
              .submitLabel(.next)
              .focused($focusedField, equals: .dateOfBirth)
          }
          
          dataRow(type: .addressAddition) {
            TextField(RowType.addressAddition.placeholder, text: viewStore.binding(\.$address.addition))
              .multilineTextAlignment(.leading)
              .keyboardType(RowType.addressAddition.keyboardType)
              .textContentType(RowType.addressAddition.textContentType)
              .disableAutocorrection(true)
              .submitLabel(.done)
              .focused($focusedField, equals: .addressAddition)
          }
        }
        Section {
          VStack(spacing: .grid(3)) {
            Image(systemName: "info.circle").font(.body)
            Text(L10n.Contact.reportHintCopy)
            Text(L10n.Contact.mailInfo)
            Text(L10n.Contact.isSavedInAppHintCopy)
          }
          .multilineTextAlignment(.center)
          .foregroundColor(Color(.secondaryLabel))
          .font(.callout)
        }
      }
      .onSubmit {
        switch focusedField {
        case .firstName:
          focusedField = .lastName
        case .lastName:
          focusedField = .street
        case .street:
          focusedField = .zipCode
        case .zipCode:
          focusedField = .city
        case .city:
          focusedField = .phone
        case .phone:
          focusedField = .dateOfBirth
        case .dateOfBirth:
          focusedField = .addressAddition
        default:
          debugPrint("Contact created")
        }
      }
    }
  }
  
  @ViewBuilder
  func dataRow(type: RowType, content: @escaping () -> some View) -> some View {
    VStack(alignment: .leading) {
      HStack {
        Text(type.label)
          .font(.callout)
          .foregroundColor(Color(.secondaryLabel))
      }
      content()
    }
  }
}

public struct ContactView: View {
  public typealias A = ContactViewDomain.Action
  public typealias S = ContactViewDomain.State
  
  let store: StoreOf<ContactViewDomain>
  @ObservedObject private var viewStore: ViewStoreOf<ContactViewDomain>
  
  public init(store: StoreOf<ContactViewDomain>) {
    self.store = store
    self.viewStore = ViewStore(store, observe: { $0 })
  }
  
  public var body: some View {
    ContactDetailsView(
      store: store.scope(
        state: \.contact,
        action: A.contact
      )
    )
    .textFieldStyle(.plain)
    .alert(store.scope(state: \.alert), dismiss: .dismissAlert)
    .navigationBarTitle(L10n.Contact.widgetTitle, displayMode: .inline)
    .toolbar {
      ToolbarItem(placement: .destructiveAction) {
        resetButton
      }
    }
    .onDisappear { viewStore.send(.onDisappear) }
  }
  
  private var resetButton: some View {
    let isButtonDisabled = viewStore.state == .empty
    return Button(
      action: { viewStore.send(.onResetContactDataButtonTapped) },
      label: {
        Image(systemName: "arrow.counterclockwise")
          .foregroundColor(isButtonDisabled ? .gray : .red)
          .accessibilityLabel(Text(L10n.Button.reset))
      }
    )
    .contentShape(Rectangle())
    .disabled(isButtonDisabled)
    .accessibility(label: Text(L10n.Report.Alert.reset))
  }
}

struct PersonalData_Previews: PreviewProvider {
  static var previews: some View {
    ContactView(
      store: Store(
        initialState: ContactViewDomain.State(),
        reducer: ContactViewDomain()
      )
    )
  }
}
