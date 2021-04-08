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
                Section {
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
                    dataRow(
                        type: .phone,
                        textFieldBinding: viewStore.binding(
                            get: \.phone,
                            send: ContactAction.phoneChanged
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
        .navigationBarTitle(L10n.Contact.widgetTitle, displayMode: .inline)
        .onDisappear { viewStore.send(.onDisappear) }
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
