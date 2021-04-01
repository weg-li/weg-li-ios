//
//  PersonalData.swift
//  weg-li
//
//  Created by Stefan Trauth on 09.10.19.
//  Copyright © 2019 Stefan Trauth. All rights reserved.
//

import ComposableArchitecture
import SwiftUI

struct ContactView: View {
    let store: Store<ContactState, ContactAction>
    
    var body: some View {
        WithViewStore(store) { viewStore in
            VStack {
                Form {
                    Section {
                        dataRow(
                            type: .firstName,
                            textFieldBinding: viewStore.binding(
                                get: { $0.firstName },
                                send: ContactAction.firstNameChanged
                            ),
                            store: viewStore
                        )
                        dataRow(
                            type: .lastName,
                            textFieldBinding: viewStore.binding(
                                get: { $0.name },
                                send: ContactAction.lastNameChanged
                            ),
                            store: viewStore
                        )
                        dataRow(
                            type: .street,
                            textFieldBinding: viewStore.binding(
                                get: { $0.address.street },
                                send: ContactAction.streetChanged
                            ),
                            store: viewStore
                        )
                        HStack {
                            dataRow(
                                type: .zipCode,
                                textFieldBinding: viewStore.binding(
                                    get: { $0.address.postalCode },
                                    send: ContactAction.zipCodeChanged
                                ),
                                store: viewStore
                            )
                            dataRow(
                                type: .town,
                                textFieldBinding: viewStore.binding(
                                    get: { $0.address.city },
                                    send: ContactAction.townChanged
                                ),
                                store: viewStore
                            )
                        }
                        dataRow(
                            type: .phone,
                            textFieldBinding: viewStore.binding(
                                get: { $0.phone },
                                send: ContactAction.phoneChanged
                            ),
                            store: viewStore
                        )
                    }
                    Section {
                        VStack {
                            Image(systemName: "lightbulb")
                                .padding(.bottom, 8)
                                .foregroundColor(.yellow)
                            Text("Deine Adresse wird lokal in der App gespeichert, um diese im Report schon vorauszufüllen.") // TODO: Move text to l18n file
                                .multilineTextAlignment(.center)
                        }
                    }
                }
            }
            .navigationBarTitle("Persönliche Daten", displayMode: .inline)
        }
    }
    
    private func dataRow(
        type: RowType,
        textFieldBinding: Binding<String>,
        store: ViewStore<ContactState, ContactAction>
    ) -> some View {
        VStack(alignment: .leading) {
            HStack {
                Text(type.label)
                    .font(.callout)
                    .foregroundColor(Color(.label))
            }
            TextField(type.placeholder, text: textFieldBinding)
                .multilineTextAlignment(.leading)
                .keyboardType(type.keyboardType)
                .textFieldStyle(PlainTextFieldStyle())
                .textContentType(type.textContentType)
        }
    }
}

struct PersonalData_Previews: PreviewProvider {
    static var previews: some View {
        ContactView(
            store: .init(
                initialState: .empty,
                reducer: .empty,
                environment: ()
            )
        )
    }
}
