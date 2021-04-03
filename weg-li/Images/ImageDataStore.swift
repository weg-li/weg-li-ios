// Created for weg-li in 2021.

import Combine
import SwiftUI

final class ImageDataStore: ObservableObject {
    let didChange = PassthroughSubject<Void, Never>()

    @Published
    var images = [UIImage]()
}
