// Created for weg-li in 2021.

import ComposableArchitecture
import SwiftUI

struct DescriptionView: View {
    struct ViewState: Equatable {
        let report: Report
        let chargeType: String

        init(state: Report) {
            report = state
            chargeType = Report.Charge.charges[state.charge.selectedType]
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
                row(title: L10n.Description.Row.carType, content: viewStore.report.car.type)
                row(title: L10n.Description.Row.carColor, content: viewStore.report.car.color)
                row(title: L10n.Description.Row.licensplateNumber, content: viewStore.report.car.licensePlateNumber)
                row(title: L10n.Description.Row.length, content: viewStore.report.charge.time)
                row(title: L10n.Description.Row.chargeType, content: viewStore.chargeType)
                if viewStore.report.charge.blockedOthers {
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
                })
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
            isCompleted: true) {
                DescriptionView(
                    store: .init(
                        initialState: Report(
                            images: ImagesViewState(),
                            contact: .preview,
                            date: Date.init,
                            location: LocationViewState(storedPhotos: [])),
                        reducer: .empty,
                        environment: ())
                )
        }
    }
}
