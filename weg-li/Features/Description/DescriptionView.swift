// Created for weg-li in 2021.

import ComposableArchitecture
import SwiftUI

struct DescriptionView: View {
    struct ViewState: Equatable {
        let description: DescriptionState
        let chargeType: String

        init(state: Report) {
            description = state.description
            chargeType = DescriptionState.charges[state.description.selectedType]
        }
    }

    let store: Store<Report, ReportAction>
    @ObservedObject private var viewStore: ViewStore<ViewState, ReportAction>

    init(store: Store<Report, ReportAction>) {
        self.store = store
        viewStore = ViewStore(store.scope(state: ViewState.init))
    }

    var body: some View {
        VStack(alignment: .leading) {
            VStack(alignment: .leading, spacing: 8) {
                row(title: L10n.Description.Row.carType, content: viewStore.description.type)
                row(title: L10n.Description.Row.carColor, content: viewStore.description.color)
                row(title: L10n.Description.Row.licensplateNumber, content: viewStore.description.licensePlateNumber)
                row(title: L10n.Description.Row.length, content: viewStore.description.time)
                row(title: L10n.Description.Row.chargeType, content: viewStore.chargeType)
                if viewStore.description.blockedOthers {
                    HStack {
                        Text(L10n.Description.Row.didBlockOthers)
                            .foregroundColor(Color(.secondaryLabel))
                            .font(.callout)
                            .fontWeight(.bold)
                        Spacer()
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.primary)
                    }
                }
            }
            NavigationLink(
                destination: EditDescriptionView(store: store),
                label: {
                    HStack {
                        Image(systemName: "pencil")
                        Text(L10n.Description.EditButton.copy)
                    }
                    .frame(maxWidth: .infinity)
                }
            )
            .buttonStyle(EditButtonStyle())
            .padding(.top)
        }
    }

    private func row(title: String, content: String) -> some View {
        VStack(alignment: .leading, spacing: 2.0) {
            Text(title)
                .foregroundColor(Color(.secondaryLabel))
                .font(.callout)
                .fontWeight(.bold)
            Text(content)
                .foregroundColor(Color(.label))
        }
    }
}

struct DescriptionWidgetView_Previews: PreviewProvider {
    static var previews: some View {
        Widget(
            title: Text("Beschreibung"),
            isCompleted: true
        ) {
            DescriptionView(
                store: .init(
                    initialState: Report(
                        images: ImagesViewState(),
                        contact: .preview,
                        date: Date.init,
                        location: LocationViewState()
                    ),
                    reducer: .empty,
                    environment: ()
                )
            )
        }
    }
}
