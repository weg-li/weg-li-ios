//
//  LocationOption.swift
//  weg-li
//
//  Created by Malte on 29.03.21.
//  Copyright © 2021 Martin Wilhelmi. All rights reserved.
//

import Foundation

enum LocationOption: Hashable, CaseIterable {
    static var allCases: [LocationOption] = [.fromPhotos(nil), .currentLocation, .manual]
    
    case fromPhotos([StorableImage]?)
    case currentLocation
    case manual
    
    var title: String {
        switch self {
        case .fromPhotos: return "Aus Fotos"
        case .currentLocation: return "Standort"
        case .manual: return "Manuell"
        }
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(self.title)
    }
}

extension LocationOption: Codable {
    private enum CodingKeys: String, CodingKey {
        case base, detailParams
    }
    
    private enum Base: String, Codable {
        case fromPhotos, currentLocation, manuel
    }
    
    private struct DetailParams: Codable {
        let images: [StorableImage]?
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        switch self {
        case .fromPhotos(let images):
            try container.encode(Base.fromPhotos, forKey: .base)
            try container.encode(DetailParams(images: images), forKey: .detailParams)
        case .currentLocation:
            try container.encode(Base.currentLocation, forKey: .base)
        case .manual:
            try container.encode(Base.manuel, forKey: .base)
        }
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let base = try container.decode(Base.self, forKey: .base)
        
        switch base {
        case .fromPhotos:
            let detailParams = try container.decode(DetailParams.self, forKey: .detailParams)
            self = .fromPhotos(detailParams.images)
        case .currentLocation:
            self = .currentLocation
        case .manuel:
            self = .manual
        }
    }
}
