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
  static func make(from pickerResult: PickerImageResult) -> Self? {
    guard let jpegData = pickerResult.jpegData else {
      return nil
    }
    
    return ImageUploadInput(
      filename: pickerResult.id,
      byteSize: UInt64(jpegData.count),
      checksum: jpegData.md5DigestBase64()
    )
  }
}

// MARK: Helper

extension Data {
  func md5DigestBase64() -> String {
    let digest = Insecure.MD5.hash(data: self)
    return Data(digest).base64EncodedString()
  }
}
