//
//  Mail.swift
//  weg-li
//
//  Created by Malte on 31.03.21.
//  Copyright © 2021 Martin Wilhelmi. All rights reserved.
//

import Foundation

struct Mail: Equatable, Codable {
    var address: String = ""
    var subject: String = "Anzeige mit der Bitte um Weiterverfolgung"
    var body: String = ""
    var attachmentData: [Data] = []
}
