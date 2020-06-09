//
//  AppState.swift
//  Wegli
//
//  Created by Malte Bünz on 08.06.20.
//  Copyright © 2020 Stefan Trauth. All rights reserved.
//

import Contacts
import Combine
import Foundation
import MapKit
import UIKit

struct Report {
    var images: [UIImage] = []
    var address: CNPostalAddress?
}

struct LocationState {
    var location: CLLocationCoordinate2D = CLLocationCoordinate2D()
    var presumedAddress: CNPostalAddress?
}

struct AppState {
    var contact: Contact?
    var report: Report
    
    var location: LocationState
}

extension CNPostalAddress {
    var humanReadableAddress: String {
        return String {
            if !street.isEmpty {
                self.street
            }
            self.postalCode
            self.city
        }
    }
}

@_functionBuilder
struct HumandReadableAddressBuilder {
    static func buildBlock(_ strings: String...) -> String {
        strings.joined(separator: " ")
    }
    
    static func buildIf(_ part: String?) -> String {
        guard let string = part else { return "" }
        return string
    }
}

extension String {
    public init(@HumandReadableAddressBuilder _ builder: () -> String) {
        self.init(builder())
    }
}
