//
//  ImageDataStore.swift
//  weg-li
//
//  Created by Stefan Trauth on 15.10.19.
//  Copyright © 2019 Stefan Trauth. All rights reserved.
//

import SwiftUI
import Combine

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
