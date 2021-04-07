// Created for weg-li in 2021.

import Foundation
import UIKit

struct StorableImage: Hashable, Identifiable {
    // default is uuidString
    let id: UUID
    let image: Data
    
    internal init(id: UUID = UUID(), image: Data) {
        self.id = id
        self.image = image
    }
    
    var asUIImage: UIImage? {
        UIImage(data: image)
    }
}

extension StorableImage {
    init?(id: UUID = UUID(), uiImage: UIImage) {
        guard let data = uiImage.pngData() else {
            return nil
        }
        image = data
        self.id = id
    }

}

extension StorableImage: Codable {}
