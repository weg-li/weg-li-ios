//
//  Description.swift
//  weg-li
//
//  Created by Stefan Trauth on 09.10.19.
//  Copyright © 2019 Stefan Trauth. All rights reserved.
//

import Combine
import SwiftUI

final class DescriptionViewModel: ObservableObject {
    @Published var carType: String = ""
    @Published var color: String = ""
    @Published var plate: String = ""
    
    let charges = Report.Charge.charges
    @Published var selectedCharge = 0

    let times = Times.allCases.map { $0.description }
    @Published var selectedTime = 0
    @Published var isSelected = false
    
    init(model: Report?) {
        guard let report = model else {
            return
        }
        print(report)
        carType = report.car.type ?? ""
        color = report.car.color ?? ""
        plate = report.car.licensePlateNumber ?? ""
        selectedCharge = report.charge.selectedType
        selectedTime = report.charge.selectedDuration
        isSelected = report.charge.blockedOthers
    }
}

struct Description: View {
    @EnvironmentObject private var appStore: AppStore
    @ObservedObject var viewModel: DescriptionViewModel
    @Binding var isPresented: Bool
    
    init(isPresented: Binding<Bool>, viewModel: DescriptionViewModel) {
        self._isPresented = isPresented
        self.viewModel = viewModel
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Fahrzeug")) {
                    TextField("Marke", text: $viewModel.carType)
                    TextField("Farbe", text: $viewModel.color)
                    TextField("Kennzeichen", text: $viewModel.plate)
                }
                .padding(.top, 4)
                .textFieldStyle(PlainTextFieldStyle())
                .font(.body)
                Section(header: Text("Verstoß")) {
                    Picker(selection: $viewModel.selectedCharge, label: Text("Art des Verstoßes")) {
                        ForEach(0 ..< self.viewModel.charges.count, id: \.self) {
                            Text(self.viewModel.charges[$0])
                        }
                    }
                    Picker(selection: $viewModel.selectedTime, label: Text("Dauer der Verstoßes")) {
                        ForEach(0 ..< self.viewModel.times.count, id: \.self) {
                            Text(self.viewModel.times[$0])
                        }
                    }
                    toggleRow
                }.pickerStyle(DefaultPickerStyle())
            }
            .navigationBarItems(
                leading: Button(action: {
                    self.storeDescription()
                    self.isPresented.toggle()
                }, label: { Text("Speichern") }),
                trailing: Button(action: {
                    self.isPresented.toggle()
                }, label: { Text("Fertig") })
            )
            .navigationBarTitle(Text("Beschreibung"), displayMode: .inline)
        }
    }
    
    private func storeDescription() {
        let car = Report.Car(color: viewModel.color, type: viewModel.carType, licensePlateNumber: viewModel.plate)
        appStore.send(.handleDescriptionAction(.setCar(car)))
        
        let charge = Report.Charge(
            selectedDuration: viewModel.selectedTime,
            selectedType: self.viewModel.selectedCharge,
            blockedOthers: viewModel.isSelected)
        appStore.send(.handleDescriptionAction(.setCharge(charge)))
    }
    
    private var toggleRow: some View {
        HStack {
            Text("Behinderung anderer Verkehrsteilnehmer")
            Spacer()
            ToggleButton(isOn: $viewModel.isSelected)
        }
    }
}

struct Description_Previews: PreviewProvider {
    static var previews: some View {
        Description(isPresented: .constant(false), viewModel: .init(model: nil))
    }
}
