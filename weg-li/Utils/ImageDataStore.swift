// Created for weg-li in 2021.

import Combine
import SwiftUI

protocol ImageDataStore {
    func add(image: UIImage)
    func remove(image: UIImage)
    func clear()
    var images: [UIImage] { get }
}

final class ReportImageDataStore: ObservableObject, ImageDataStore {
    @Published
    private(set) var images = [UIImage]()

    func add(image: UIImage) {
        images.append(image)
    }

    func remove(image: UIImage) {
        if let index = images.firstIndex(of: image) {
            images.remove(at: index)
        }
    }

    func clear() {
        images.removeAll()
    }
}
