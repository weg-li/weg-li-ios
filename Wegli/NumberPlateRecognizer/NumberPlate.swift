//
//  NumberPlate.swift
//  Wegli
//
//  Created by Eugen Pirogoff on 26.11.19.
//  Copyright © 2019 Stefan Trauth. All rights reserved.
//

import Foundation
import OpenALPRSwift

struct NumberPlate: CustomStringConvertible {
    let value: String
    let confidence: Float
    var imageName: String?

    private init(imageName: String? = nil, value: String, confidence: Float) {
        self.confidence = confidence
        self.value = value
        self.imageName = imageName
    }

    init?(from plate: OAPlate, imageName: String? = nil ) {
        guard let characters = plate.characters else {
            return nil
        }

        let plateString = characters.reduce(String("")) { (summaryString, oacharacter) -> String in
            guard let character = oacharacter.character else {
                return summaryString
            }
            var newSummaryString = summaryString
            newSummaryString.append(character)
            return newSummaryString
        }

        self = NumberPlate(imageName: imageName, value: String(plateString), confidence: plate.confidence)
    }

    var description: String {
        if let imageName = imageName {
            return "ImageName: \(imageName), Value: \(value), Confidence: \(confidence.description)"
        } else {
            return "ImageName: nil, Value: \(value), Confidence: \(confidence.description)"
        }
    }
}
