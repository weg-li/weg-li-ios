// Created for weg-li in 2021.

import ComposableArchitecture
import SwiftUI

struct ContactWidget: View {
    struct ViewState: Equatable {
        let firstName: String
        let name: String
        let street: String
        let postalCode: String
        let city: String
        let phone: String
        let dateOfBirth: String
        let addressAddition: String
        let showEditScreen: Bool
        let isResetButtonDisabled: Bool

        init(state: Report) {
            firstName = state.contact.firstName
            name = state.contact.name
            street = state.contact.address.street
            postalCode = state.contact.address.postalCode
            city = state.contact.address.city
            phone = state.contact.phone
            dateOfBirth = state.contact.dateOfBirth
            addressAddition = state.contact.address.addition
            showEditScreen = state.showEditContact
            isResetButtonDisabled = state.contact == .empty
        }
    }

    let store: Store<Report, ReportAction>
    @ObservedObject private var viewStore: ViewStore<ViewState, ReportAction>

    init(store: Store<Report, ReportAction>) {
        self.store = store
        viewStore = ViewStore(store.scope(state: ViewState.init))
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            row(callout: L10n.Contact.Row.nameCopy, content: "\(viewStore.firstName) \(viewStore.name)")
            row(callout: L10n.Contact.Row.streetCopy, content: viewStore.street)
            row(callout: L10n.Contact.Row.cityCopy, content: "\(viewStore.postalCode) \(viewStore.city)")
            if !viewStore.phone.isEmpty {
                row(callout: L10n.Contact.Row.phoneCopy, content: viewStore.phone)
            }
            if !viewStore.dateOfBirth.isEmpty {
                row(callout: L10n.Contact.Row.dateOfBirth, content: viewStore.dateOfBirth)
            }
            if !viewStore.addressAddition.isEmpty {
                row(callout: L10n.Contact.Row.addressAddition, content: viewStore.addressAddition)
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
                            state: { $0.contact },
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
            }
        )
        .disabled(viewStore.isResetButtonDisabled)
    }

    private func row(callout: String, content: String) -> some View {
        HStack {
            Text(callout)
                .foregroundColor(Color(.secondaryLabel))
                .font(.callout)
                .fontWeight(.bold)
            Spacer()
            Text(content)
                .foregroundColor(Color(.label))
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
