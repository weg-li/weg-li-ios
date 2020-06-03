//
//  PersonalDataStore.swift
//  Wegli
//
//  Created by Stefan Trauth on 09.10.19.
//  Copyright © 2019 Stefan Trauth. All rights reserved.
//

import Combine

final class PersonalDataStore: ObservableObject {
    let didChange = PassthroughSubject<Void, Never>()

    @UserDefault(key: "personalData_name", defaultValue: "")
    var name: String {
        didSet {
            didChange.send()
        }
    }
    
    @UserDefault(key: "personalData_street", defaultValue: "")
    var street: String {
        didSet {
            didChange.send()
        }
    }
    
    @UserDefault(key: "personalData_town", defaultValue: "")
    var town: String {
        didSet {
            didChange.send()
        }
    }
    
    @UserDefault(key: "personalData_phone", defaultValue: "")
    var phone: String {
        didSet {
            didChange.send()
        }
    }
}
