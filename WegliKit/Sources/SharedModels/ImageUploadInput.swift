import CryptoKit
import Foundation
import UIKit

/// A structure that represents the request body for the `/api/uploads` API call
public struct ImageUploadInput: Codable, Equatable {
  public let filename: String
  public let byteSize: UInt64
  /// MD5 base64digest of file
  public let checksum: String
  var contentType = "image/jpeg"
  
  public init(
    filename: String,
    byteSize: UInt64,
    checksum: String
  ) {
    self.filename = filename
    self.byteSize = byteSize
    self.checksum = checksum
  }
}

public extension ImageUploadInput {
  static func make(id: PickerImageResult.ID, data: Data) -> Self {
    ImageUploadInput(
      filename: id,
      byteSize: UInt64(data.count),
      checksum: data.md5DigestBase64()
    )
  }
}

// MARK: Helper

extension Data {
  func md5DigestBase64() -> String {
    // Calculate MD5 hash
    let md5Hash = Insecure.MD5.hash(data: self)
    // Convert hash to Data
    let md5Data = Data(md5Hash)
    // Base64 encode the MD5 hash
    let base64Encoded = md5Data.base64EncodedString()
    
    return base64Encoded
  }
}
