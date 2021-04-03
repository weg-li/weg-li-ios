// Created for weg-li in 2021.

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

    var asUIImage: UIImage? {
        UIImage(data: image)
    }
}
