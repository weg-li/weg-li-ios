//
//  DescriptionWidgetView.swift
//  weg-li
//
//  Created by Malte Bünz on 14.06.20.
//  Copyright © 2020 Stefan Trauth. All rights reserved.
//

import ComposableArchitecture
import SwiftUI

struct Description: View {
    struct ViewState: Equatable {
        let report: Report
        let type: String
        let color: String
        let license: String
        let time: String
        let chargeType: String
        
        init(state: Report) {
            report = state

            self.type = state.car.type ?? ""
            self.color = state.car.color ?? ""
            self.license = state.car.licensePlateNumber ?? ""
            self.time = state.charge.time
            self.chargeType = Report.Charge.charges[state.charge.selectedType]
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
                row(title: "Marke:", content: viewStore.type)
                row(title: "Farbe:", content: viewStore.color)
                row(title: "Kennzeichen:", content: viewStore.license)
                row(title: "Dauer:", content: viewStore.time)
                row(title: "Art des Verstoßes:", content: viewStore.chargeType)
                if viewStore.report.charge.blockedOthers {
                    HStack {
                        Text("Behinderung anderer Verkehrsteilnehmer") // TODO: l18n
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
                destination: EditDescription(store: store),
                label: {
                    HStack {
                        Image(systemName: "pencil")
                        Text("Beschreibung bearbeiten") // TODO: l18n
                    }
                    .frame(maxWidth: .infinity)
                }
            )
            .buttonStyle(EditButtonStyle())
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
            Description(
                store: .init(
                    initialState: Report(contact: .preview),
                    reducer: .empty,
                    environment: ()
                )
            )
        }
    }
}
