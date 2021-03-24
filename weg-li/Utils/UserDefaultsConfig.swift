//
//  UserDefaultsConfig.swift
//  weg-li
//
//  Created by Malte on 24.03.21.
//  Copyright © 2021 Martin Wilhelmi. All rights reserved.
//

import Foundation

enum UserDefaultsConfig {
    @Storage(key: "contactData", defaultValue: .empty)
    static var contact: ContactState
    
    @Storage(key: "reports", defaultValue: [Report]())
    static var reports: [Report]
    
    @Storage(key: "draftReport", defaultValue: nil)
    static var draftReport: Report?
}
