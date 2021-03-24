//
//  StorableImage.swift
//  weg-li
//
//  Created by Malte on 20.03.21.
//  Copyright © 2021 Martin Wilhelmi. All rights reserved.
//

import Foundation
import UIKit

struct StorableImage: Equatable, Codable {
    let image: Data
    
    init?(uiImage: UIImage) {
        guard let data = uiImage.pngData() else {
            return nil
        }
        image = data
    }
}
