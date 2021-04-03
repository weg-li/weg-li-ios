//
//  PersonalDataWidget.swift
//  weg-li
//
//  Created by Malte Bünz on 04.06.20.
//  Copyright © 2020 Stefan Trauth. All rights reserved.
//

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
        
        init(state: ContactState) {
            self.firstName = state.firstName
            self.name = state.name
            self.street = state.address.street
            self.postalCode = state.address.postalCode
            self.city = state.address.city
            self.phone = state.phone
        }
    }
    let store: Store<ContactState, ReportAction>
    @ObservedObject private var viewStore: ViewStore<ViewState, ReportAction>
    
    init(store: Store<ContactState, ReportAction>) {
        self.store = store
        self.viewStore = ViewStore(store.scope(state: ViewState.init))
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            row(callout: "Name", content: ("\(viewStore.firstName) \(viewStore.name)"))
            row(callout: "Straße", content: viewStore.street)
            row(callout: "Stadt", content: "\(viewStore.postalCode) \(viewStore.city)")
            row(callout: "Telefon", content: viewStore.phone)
            VStack(spacing: 8.0) {
                NavigationLink(
                    destination: ContactView(
                        store: store.scope(
                            state: { $0 },
                            action: ReportAction.contact
                        )
                    ),
                    label: {
                        Text("Kontaktdaten bearbeiten") // TODO: l18n
                            .frame(maxWidth: .infinity)
                    }
                )
                .buttonStyle(EditButtonStyle())
                .padding(.top)
                Text("Die Anzeige kann nur bearbeitet werden, wenn du richtige Angaben zu deiner Person machst.") // TODO: l18n
                    .font(.footnote)
                    .foregroundColor(.gray)
            }
            .fixedSize(horizontal: false, vertical: true)
        }
        .onAppear {
            viewStore.send(.viewAppeared)
        }
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
