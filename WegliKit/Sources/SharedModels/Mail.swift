// Created for weg-li in 2021.

import Foundation

public struct Mail: Equatable, Codable {
  public init(
    address: String = "",
    subject: String = "Anzeige mit der Bitte um Weiterverfolgung",
    body: String = "",
    attachmentData: [Data] = []
  ) {
    self.address = address
    self.subject = subject
    self.body = body
    self.attachmentData = attachmentData
  }
  
  public var address: String
  public var subject: String
  public var body: String
  public var attachmentData: [Data]
}
