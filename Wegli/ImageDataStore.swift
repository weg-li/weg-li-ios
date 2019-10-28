//
//  ImageDataStore.swift
//  Wegli
//
//  Created by Stefan Trauth on 15.10.19.
//  Copyright © 2019 Stefan Trauth. All rights reserved.
//

import SwiftUI
import Combine

final class ImageDataStore: ObservableObject {
    @Published
    var images = [UIImage]()
}
