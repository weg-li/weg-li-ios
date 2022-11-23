import Foundation

public struct ImageUploadResponse: Codable, Equatable {
  public var id: Int?
  public let key: String
  public let filename: String
  public let contentType: String
  public let byteSize: Int64
  public let checksum: String
  public let createdAt: Date
  public let signedId: String
  public let directUpload: DirectUpload
  
  public init(
    id: Int,
    key: String,
    filename: String,
    contentType: String,
    byteSize: Int64,
    checksum: String,
    createdAt: Date,
    signedId: String,
    directUpload: DirectUpload
  ) {
    self.id = id
    self.key = key
    self.filename = filename
    self.contentType = contentType
    self.byteSize = byteSize
    self.checksum = checksum
    self.createdAt = createdAt
    self.signedId = signedId
    self.directUpload = directUpload
  }
  
  public struct DirectUpload: Codable, Equatable {
    public init(
      url: String,
      headers: [String: String]
    ) {
      self.url = url
      self.headers = headers
    }
    
    public let url: String
    public let headers: [String: String]
  }
}
