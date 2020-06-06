//
//  PersonalDataStore.swift
//  Wegli
//
//  Created by Stefan Trauth on 09.10.19.
//  Copyright © 2019 Stefan Trauth. All rights reserved.
//

import Combine
import Foundation

final class PersonalDataViewModel: ObservableObject {
    private let repository: PersonsalDataRepository
    
    @Published var firstName: String
    @Published var name: String
    @Published var street: String
    @Published var zipCode: String
    @Published var town: String
    @Published var phone: String
    
    @Published var isFirstNameValid: Bool = false
    @Published var isNameValid: Bool = false
    @Published var isStreetValid: Bool = false
    @Published var isZipCodeValid: Bool = false
    @Published var isTownValid: Bool = false
    @Published var isPhoneValid: Bool = false
    @Published var isFormValid: Bool =  false
    
    private var bag = Set<AnyCancellable>()
    
    init(repository: PersonsalDataRepository = PersonsalDataRepository()) {
        self.repository = repository
        
        self.firstName = repository.user.firstName
        self.name = repository.user.name
        self.street = repository.user.address.street
        self.zipCode = repository.user.address.zipCode
        self.town = repository.user.address.town
        self.phone = repository.user.phone
        
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
        
        _ = $isFirstNameValid.merge(with: $isNameValid, $isStreetValid, $isTownValid, $isPhoneValid, $isZipCodeValid)
            .assign(to: \.isFormValid, on: self)
            .store(in: &bag)
    }
    
    func send(event: Event) {
        switch event {
        case .storeUser:
            repository.user = User(
                firstName: firstName,
                name: name,
                address: .init(street: street, zipCode: zipCode, town: town),
                phone: phone
            )
        }
    }
}

extension PersonalDataViewModel {
    enum Event {
        case storeUser
    }
}
