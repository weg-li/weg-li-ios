//
//  PersonalDataStore+Validation.swift
//  Wegli
//
//  Created by Stefan Trauth on 09.10.19.
//  Copyright © 2019 Stefan Trauth. All rights reserved.
//

import Foundation

extension PersonalDataStore {
    var isValid: Bool {
        guard isNameValid else { return false }
        guard isStreetValid else { return false }
        guard isTownValid else { return false }
        guard isPhoneValid else { return false }
        return true
    }
    
    var isNameValid: Bool {
        guard !name.isEmpty else { return false }
        return true
    }
    
    var isStreetValid: Bool {
        guard !street.isEmpty else { return false }
        return true
    }
    
    var isTownValid: Bool {
        guard !town.isEmpty else { return false }
        return true
    }
    
    var isPhoneValid: Bool {
        guard !phone.isEmpty else { return false }
        return true
    }
}
