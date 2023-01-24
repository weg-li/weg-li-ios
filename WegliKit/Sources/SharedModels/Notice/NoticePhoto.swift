import Foundation

public struct NoticePhoto: Hashable, Codable {
  public let filename: String
  public let url: String
  
  public init(filename: String, url: String) {
    self.filename = filename
    self.url = url
  }
}
