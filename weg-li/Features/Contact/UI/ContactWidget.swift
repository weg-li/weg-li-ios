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

        init(state: ContactState) {
            firstName = state.firstName
            name = state.name
            street = state.address.street
            postalCode = state.address.postalCode
            city = state.address.city
            phone = state.phone
        }
    }

    let store: Store<ContactState, ReportAction>
    @ObservedObject private var viewStore: ViewStore<ViewState, ReportAction>

    init(store: Store<ContactState, ReportAction>) {
        self.store = store
        viewStore = ViewStore(store.scope(state: ViewState.init))
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            row(callout: L10n.Contact.Row.nameCopy, content: "\(viewStore.firstName) \(viewStore.name)")
            row(callout: L10n.Contact.Row.streetCopy, content: viewStore.street)
            row(callout: L10n.Contact.Row.cityCopy, content: "\(viewStore.postalCode) \(viewStore.city)")
            row(callout: L10n.Contact.Row.phoneCopy, content: viewStore.phone)
            VStack(spacing: 8.0) {
                NavigationLink(
                    destination: ContactView(
                        store: store.scope(
                            state: { $0 },
                            action: ReportAction.contact
                        )
                    ),
                    label: {
                        Text(L10n.Contact.editButtonCopy)
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
