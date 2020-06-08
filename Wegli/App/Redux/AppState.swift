//
//  AppState.swift
//  Wegli
//
//  Created by Malte Bünz on 08.06.20.
//  Copyright © 2020 Stefan Trauth. All rights reserved.
//

import Foundation
import UIKit

struct Report {
    var images: [UIImage] = []
}

struct AppState {
    var contact: Contact?
    var report: Report
    
}
