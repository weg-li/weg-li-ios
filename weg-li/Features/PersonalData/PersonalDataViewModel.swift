//
//  PersonalDataStore.swift
//  weg-li
//
//  Created by Stefan Trauth on 09.10.19.
//  Copyright © 2019 Stefan Trauth. All rights reserved.
//

import Combine
import Foundation

final class PersonalDataViewModel: ObservableObject {
    @Published var firstName: String
    @Published var name: String
    @Published var street: String
    @Published var zipCode: String
    @Published var town: String
    @Published var phone: String
    @Published var email: String
    
    @Published var isFirstNameValid = false
    @Published var isNameValid = false
    @Published var isStreetValid = false
    @Published var isZipCodeValid = false
    @Published var isTownValid = false
    @Published private var isAddressValid =  false
    @Published var isPhoneValid = false
    @Published var isMailValid = false
    
    @Published var isFormValid =  false
    
    private var bag = Set<AnyCancellable>()
    
    init(model: Contact?) {
       self.firstName = model?.firstName ?? ""
        self.name = model?.name ?? ""
        self.street = model?.address.street ?? ""
        self.zipCode = model?.address.zipCode ?? ""
        self.town = model?.address.town ?? ""
        self.phone = model?.phone ?? ""
        self.email = model?.mail ?? ""
        
        $firstName
            .removeDuplicates()
            .map { !$0.isEmpty }
            .assign(to: \.isFirstNameValid, on: self)
            .store(in: &bag)
        $name
            .removeDuplicates()
            .map { !$0.isEmpty }
            .assign(to: \.isNameValid, on: self)
            .store(in: &bag)
        $street
            .removeDuplicates()
            .map { !$0.isEmpty }
            .assign(to: \.isStreetValid, on: self)
            .store(in: &bag)
        $zipCode
            .removeDuplicates()
            .map { $0.count == 5 && CharacterSet.decimalDigits.isSuperset(of: CharacterSet(charactersIn: $0)) }
            .assign(to: \.isZipCodeValid, on: self)
            .store(in: &bag)
        $town
            .removeDuplicates()
            .map { !$0.isEmpty }
            .assign(to: \.isTownValid, on: self)
            .store(in: &bag)
        $phone
            .removeDuplicates()
            .map { !$0.isEmpty }
            .assign(to: \.isPhoneValid, on: self)
            .store(in: &bag)
        
        $email
            .removeDuplicates()
            .map { !$0.isEmpty }
            .assign(to: \.isMailValid, on: self)
            .store(in: &bag)
        
        _ = $isZipCodeValid.combineLatest($isStreetValid, $isTownValid)
            .receive(on: RunLoop.main)
            .map { $0 && $1 && $2 }
            .assign(to: \.isAddressValid, on: self)
            .store(in: &bag)
        
        _ = $isAddressValid.combineLatest($isNameValid, $isFirstNameValid, $isPhoneValid)
            .receive(on: RunLoop.main)
            .map { $0 && $1 && $2 && $3 }
            .assign(to: \.isFormValid, on: self)
            .store(in: &bag)
    }
}
