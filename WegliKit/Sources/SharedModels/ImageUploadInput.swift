import Foundation

public struct ImageUploadInput: Codable, Equatable {
  public let filename: String
  public let byteSize: UInt64
  /// MD5 base64digest of file
  public let checksum: String
  public var contentType: String = "image/jpeg"
  
  public init(
    filename: String,
    byteSize: UInt64,
    checksum: String,
    contentType: String = "image/jpeg"
  ) {
    self.filename = filename
    self.byteSize = byteSize
    self.checksum = checksum
    self.contentType = contentType
  }
}
