//
//  ImageDataStore.swift
//  weg-li
//
//  Created by Stefan Trauth on 15.10.19.
//  Copyright © 2019 Stefan Trauth. All rights reserved.
//

import SwiftUI
import Combine

final class ImageDataStore: ObservableObject {
    let didChange = PassthroughSubject<Void, Never>()
    
    @Published
    var images = [UIImage]()
}
