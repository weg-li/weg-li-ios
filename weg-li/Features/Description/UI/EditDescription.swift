//
//  Description.swift
//  weg-li
//
//  Created by Stefan Trauth on 09.10.19.
//  Copyright © 2019 Stefan Trauth. All rights reserved.
//

import ComposableArchitecture
import SwiftUI

struct EditDescription: View {
    struct ViewState: Equatable, Hashable {
        let report: Report
        let carType: String
        let carColor: String
        let licensePlate: String
        let blockedOthers: Bool
        let charge: Report.Charge
        let selectedCharge: Int
        
        init(state: Report) {
            self.report = state
            self.carType = state.car.type ?? "" // TODO: l18n
            self.carColor = state.car.color ?? "" // TODO: l18n
            self.licensePlate = state.car.licensePlateNumber ?? "" // TODO: l18n
            self.blockedOthers = state.charge.blockedOthers
            self.charge = state.charge
            self.selectedCharge = state.charge.selectedType
        }
        
        func hash(into hasher: inout Hasher) {}
    }
    
    let store: Store<Report, ReportAction>
    @ObservedObject private var viewStore: ViewStore<ViewState, ReportAction>
    
    init(store: Store<Report, ReportAction>) {
        self.store = store
        self.viewStore = ViewStore(store.scope(state: ViewState.init))
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Fahrzeug")) { // TODO: l18n
                    TextField(
                        "Marke", // TODO: l18n
                        text: viewStore.binding(
                            get: \.carType,
                            send:  { ReportAction.car(.type($0)) }
                        )
                    )
                    TextField(
                        "Farbe", // TODO: l18n
                        text: viewStore.binding(
                            get: \.carColor,
                            send:  { ReportAction.car(.color($0)) }
                        )
                    )
                    TextField(
                        "Kennzeichen", // TODO: l18n
                        text: viewStore.binding(
                            get: \.licensePlate,
                            send:  { ReportAction.car(.licensePlateNumber($0)) }
                        )
                    )
                }
                .padding(.top, 4)
                .textFieldStyle(PlainTextFieldStyle())
                .font(.body)
                Section(header: Text("Verstoß")) { // TODO: l18n
                    Picker(
                        "Art des Verstoßes", // TODO: l18n
                        selection: viewStore.binding(
                            get: \.charge.selectedType,
                            send: { ReportAction.charge(.selectCharge($0)) }
                        )
                    ) {
                        ForEach(0 ..< Report.Charge.charges.count, id: \.self) { chargeIndex in
                            Text(Report.Charge.charges[chargeIndex])
                                .tag(chargeIndex)
                        }
                    }
                    Picker(
                        "Dauer der Verstoßes", // TODO: l18n
                        selection: viewStore.binding(
                            get: \.charge.selectedDuration,
                            send: { ReportAction.charge(.selectDuraration($0)) }
                        )
                    ) {
                        ForEach(0 ..< Times.allCases.count, id: \.self) {
                            Text(Times.allCases[$0].description)
                        }
                    }
                    toggleRow
                }.pickerStyle(DefaultPickerStyle())
            }
            .navigationBarTitle(Text("Beschreibung"), displayMode: .inline) // TODO: l18n
        }
    }
        
    private var toggleRow: some View {
        HStack {
            Text("Behinderung anderer Verkehrsteilnehmer") // TODO: l18n
            Spacer()
            ToggleButton(
                isOn: viewStore.binding(
                    get: \.blockedOthers,
                    send: { _ in ReportAction.charge(.toggleBlockedOthers) }
                )
            )
        }
    }
}

struct Description_Previews: PreviewProvider {
    static var previews: some View {
        EditDescription(
            store: .init(
                initialState: .init(contact: .preview),
                reducer: .empty,
                environment: ()
            )
        )
    }
}
