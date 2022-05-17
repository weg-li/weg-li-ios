import ComposableArchitecture
import Foundation
import SharedModels

public struct ImagesUploadClient {
  var uploadImages: ([PickerImageResult]) -> Effect<Result<[String], NSError>, Never>

  public init(uploadImages: @escaping ([PickerImageResult]) -> Effect<Result<[String], NSError>, Never>) {
    self.uploadImages = uploadImages
  }
}

public extension ImagesUploadClient {
  static let live = Self(
    uploadImages: { images in
      return .none
    }
  )
}

public struct ImageUploadInput {
  let filename: String
  let byteSize: UInt64
  /// MD5 base64digest of file
  let checksum: String
  var contentType: String = "image/jpeg"
}
