//
//  PersonalData.swift
//  Wegli
//
//  Created by Stefan Trauth on 09.10.19.
//  Copyright © 2019 Stefan Trauth. All rights reserved.
//

import SwiftUI

struct PersonalData: View {
    @Binding var isPresented: Bool
    @ObservedObject var viewModel: PersonalDataViewModel
    @EnvironmentObject private var appStore: AppStore
    
    var body: some View {
        VStack {
            HStack {
                Button(action: {
                    self.appStore.send(.setContact(
                        Contact(
                            firstName: self.viewModel.firstName,
                            name: self.viewModel.name,
                            address: .init(
                                street: self.viewModel.street,
                                zipCode: self.viewModel.zipCode,
                                town: self.viewModel.town),
                            phone: self.viewModel.phone)
                        )
                    )
                    self.isPresented.toggle()
                }) {
                    Text("Speichern")
                }.disabled(!viewModel.isFormValid)
                Spacer()
                Button(action: {
                    self.isPresented.toggle()
                }) {
                    Text("Abbrechen")
                }
            }.padding()
            Form {
                Section {
                    DataRow(type: .firstName, text: $viewModel.firstName, isValid: $viewModel.isFirstNameValid)
                    DataRow(type: .lastName, text: $viewModel.name, isValid: $viewModel.isNameValid)
                    DataRow(type: .street, text: $viewModel.street, isValid: $viewModel.isStreetValid)
                    HStack {
                        DataRow(type: .zipCode, text: $viewModel.zipCode, isValid: $viewModel.isZipCodeValid)
                        DataRow(type: .town, text: $viewModel.town, isValid: $viewModel.isTownValid)
                    }
                    DataRow(type: .phone, text: $viewModel.phone, isValid: $viewModel.isPhoneValid)
                }
            }
        }
        .navigationBarTitle("Persönliche Daten", displayMode: .inline)
    }
}

struct PersonalData_Previews: PreviewProvider {
    static var previews: some View {
        PersonalData(isPresented: .constant(true), viewModel: PersonalDataViewModel(model: nil))
    }
}
