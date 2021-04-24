// Created for weg-li in 2021.

import ComposableArchitecture
import SwiftUI

struct ContactView: View {
    let store: Store<ContactState, ContactAction>
    @ObservedObject private var viewStore: ViewStore<ContactState, ContactAction>

    init(store: Store<ContactState, ContactAction>) {
        self.store = store
        viewStore = ViewStore(store)
    }

    var body: some View {
        VStack {
            Form {
                Section(header: Text(L10n.Contact.Section.required)) {
                    dataRow(
                        type: .firstName,
                        textFieldBinding: viewStore.binding(
                            get: \.firstName,
                            send: ContactAction.firstNameChanged
                        )
                    )
                    dataRow(
                        type: .lastName,
                        textFieldBinding: viewStore.binding(
                            get: \.name,
                            send: ContactAction.lastNameChanged
                        )
                    )
                    dataRow(
                        type: .street,
                        textFieldBinding: viewStore.binding(
                            get: \.address.street,
                            send: ContactAction.streetChanged
                        )
                    )
                    HStack {
                        dataRow(
                            type: .zipCode,
                            textFieldBinding: viewStore.binding(
                                get: \.address.postalCode,
                                send: ContactAction.zipCodeChanged
                            )
                        )
                        dataRow(
                            type: .town,
                            textFieldBinding: viewStore.binding(
                                get: \.address.city,
                                send: ContactAction.townChanged
                            )
                        )
                    }
                }
                Section(header: Text(L10n.Contact.Section.optional)) {
                    dataRow(
                        type: .phone,
                        textFieldBinding: viewStore.binding(
                            get: \.phone,
                            send: ContactAction.phoneChanged
                        )
                    )
                    dataRow(
                        type: .dateOfBirth,
                        textFieldBinding: viewStore.binding(
                            get: \.dateOfBirth,
                            send: ContactAction.dateOfBirthChanged
                        )
                    )
                    dataRow(
                        type: .addressAddition,
                        textFieldBinding: viewStore.binding(
                            get: \.address.addition,
                            send: ContactAction.addressAdditionChanged
                        )
                    )
                }
                Section {
                    VStack {
                        Image(systemName: "info.circle")
                            .padding(.bottom, 4)
                        Text(L10n.Contact.isSavedInAppHintCopy)
                            .multilineTextAlignment(.center)
                            .font(.callout)
                    }
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
            }
        )
        .disabled(isButtonDisabled)
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
        Preview {
            ContactView(
                store: .init(
                    initialState: .preview,
                    reducer: .empty,
                    environment: ()
                )
            )
        }
    }
}
