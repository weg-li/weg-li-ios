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
    var fullName: String { contact.fullName }
    var city: String { contact.address.city }
    
    init(state: ReportDomain.State) {
      self.isResetButtonDisabled = state.contactState == .empty
      self.contact = state.contactState.contact
      self.showEditScreen = state.showEditContact
    }
  }
  
  public let store: Store<ReportDomain.State, ReportDomain.Action>
  @ObservedObject private var viewStore: ViewStore<ViewState, ReportDomain.Action>
  
  public init(store: Store<ReportDomain.State, ReportDomain.Action>) {
    self.store = store
    self.viewStore = ViewStore(store.scope(state: ViewState.init))
  }
  
  public var body: some View {
    VStack(alignment: .leading, spacing: .grid(2)) {
      VStack(alignment: .leading, spacing: .grid(2)) {
        row(callout: L10n.Contact.Row.nameCopy, content: viewStore.fullName)
        row(callout: L10n.Contact.Row.streetCopy, content: viewStore.contact.address.street)
        row(callout: L10n.Contact.Row.cityCopy, content: viewStore.city)
        if !viewStore.contact.phone.isEmpty {
          row(callout: L10n.Contact.Row.phoneCopy, content: viewStore.contact.phone)
        }
        if !viewStore.contact.dateOfBirth.isEmpty {
          row(callout: L10n.Contact.Row.dateOfBirth, content: viewStore.contact.dateOfBirth)
        }
        if !viewStore.contact.address.addition.isEmpty {
          row(callout: L10n.Contact.Row.addressAddition, content: viewStore.contact.address.addition)
        }
      }
      .accessibilityElement(children: .combine)
      VStack(spacing: .grid(2)) {
        Button(
          action: { viewStore.send(.setShowEditContact(true)) },
          label: {
            Label(L10n.Contact.editButtonCopy, systemImage: "square.and.pencil")
              .frame(maxWidth: .infinity)
          }
        )
        .accessibilitySortPriority(3)
        .buttonStyle(.edit())
        .padding(.top)
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
        send: ReportDomain.Action.setShowEditContact
      ), content: {
        NavigationView {
          ContactView(
            store: store.scope(
              state: \.contactState,
              action: ReportDomain.Action.contact
            )
          )
          .accessibilityAddTraits([.isModal])
          .navigationBarItems(
            leading: Button(
              action: { viewStore.send(.setShowEditContact(false)) },
              label: { Text(L10n.Button.close) }
            )
          )
        }
      }
    )
  }
  
  private func row(callout: String, content: String) -> some View {
    HStack {
      Text(callout)
        .foregroundColor(Color(.secondaryLabel))
        .font(.callout)
      if !content.isEmpty {
        Spacer()
        Text(content)
          .foregroundColor(Color(.label))
          .font(.body)
      }
    }
    .accessibilityElement(children: .combine)
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
