//
//  ExifReader.swift
//  Wegli
//
//  Created by Malte Bünz on 02.06.20.
//  Copyright © 2020 Stefan Trauth. All rights reserved.
//

import CoreLocation
import Combine
import Foundation
import ImageIO
import UIKit

enum ExifReaderError: Error {
    case imagesIsNil
}

final class ExifReader {
    func readLocationMetaData(from images: [UIImage]?) {
        guard let images = images else {
            return
        }
        let metaData = readMetaData(from: images)
        print(metaData)
    }
    
    private func readMetaData(from images: [UIImage]) -> [[String: AnyObject?]] {
        var metaData: [CFDictionary] = []
        for image in images {
            var jpeg: Data? = nil
            if let image1 = image.jpegData(compressionQuality: 98) {
                jpeg = Data(image1)
            }
            var source: CGImageSource? = nil
            if let jpeg = jpeg as CFData? {
                source = CGImageSourceCreateWithData(jpeg, nil)
            }
            var imageMetaData: CFDictionary? = nil
            if let source = source {
                imageMetaData = CGImageSourceCopyPropertiesAtIndex(source, 0, nil)
            }
            if let imageMetaData = imageMetaData {
                metaData.append(imageMetaData)
            }
        }
        return metaData.compactMap { $0 as? [String: AnyObject?] }
    }
}
