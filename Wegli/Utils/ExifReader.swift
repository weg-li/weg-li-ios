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
            if let imageMetaData = image.getExifData() {
                metaData.append(imageMetaData)
            }
        }
        return metaData
            .compactMap { $0 as? [String: AnyObject?] }
    }
}

private extension UIImage {
    func getExifData() -> CFDictionary? {
        var exifData: CFDictionary? = nil
        if let data = self.jpegData(compressionQuality: 1.0) {
            data.withUnsafeBytes {
                let bytes = $0.baseAddress?.assumingMemoryBound(to: UInt8.self)
                if let cfData = CFDataCreate(kCFAllocatorDefault, bytes, data.count),
                    let source = CGImageSourceCreateWithData(cfData, nil) {
                    exifData = CGImageSourceCopyPropertiesAtIndex(source, 0, nil)
                }
            }
        }
        return exifData
    }
}
