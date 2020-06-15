//
//  Description.swift
//  Wegli
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
    
    let crimes = ["Stand auf der Radspur", "Core Data", "Core Data", "Core Data"]
    @Published var selectedcrime = 0
    
    let times = ["30 Minuten", "1 Stunde", "2 Stunden"]
    @Published var selectedTime = 0
    
    @Published var isSelected = false
    
    @Published var wasEdited: Bool = false
    
    init(model: Report?) {
        guard let report = model else {
            return
        }
        self.carType = report.car.type ?? ""
        color = report.car.color ?? ""
        plate = report.car.licensePlateNumber ?? ""
        
        selectedcrime = 0
        selectedTime = 0
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
                    TextField("Marke", text: $viewModel.carType, onEditingChanged: { _ in self.viewModel.wasEdited = true })
                    TextField("Farbe", text: $viewModel.color, onEditingChanged: { _ in self.viewModel.wasEdited = true })
                    TextField("Kennzeichen", text: $viewModel.plate, onEditingChanged: { _ in self.viewModel.wasEdited = true })
                }
                .padding(.top, 4)
                .textFieldStyle(PlainTextFieldStyle())
                .font(.body)
                Section(header: Text("Verstoß")) {
                    Picker(selection: $viewModel.selectedcrime, label: Text("Art des Verstoßes")) {
                        ForEach(0 ..< viewModel.crimes.count, id: \.self) {
                            Text(self.viewModel.crimes[$0])
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
            .onAppear { print(self.appStore) }
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
        
        let crime = Report.Crime(
            duration: viewModel.times[viewModel.selectedTime],
            type: viewModel.crimes[viewModel.selectedcrime],
            blockedOthers: viewModel.isSelected)
        appStore.send(.handleDescriptionAction(.setCrime(crime)))
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

struct ToggleButton: View {
    @Binding private(set) var isOn: Bool
    
    var body: some View {
        Button(action: {
            self.isOn.toggle()
        }, label: {
            self.content
        })
    }
    
    private var content: some View {
        if isOn {
            return Image(systemName: "checkmark.circle.fill")
                .resizable()
                .frame(width: 35, height: 35)
                .foregroundColor(.green)
                .eraseToAnyView()
        } else {
            return Image(systemName: "checkmark.circle.fill")
                .hidden()
                .frame(width: 35, height: 35)
                .overlay(
                    Circle()
                        .strokeBorder(Color.gray, lineWidth: 1)
            )
                .eraseToAnyView()
        }
    }
}
