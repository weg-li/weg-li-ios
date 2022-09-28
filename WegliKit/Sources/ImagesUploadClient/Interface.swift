import ApiClient
import Foundation
import SharedModels

public struct ImagesUploadClient {
  public var uploadImages: ([UploadImageRequest]) async throws -> [ImageUploadResponse]
  
  public init(uploadImages: @escaping ([UploadImageRequest]) async throws -> [ImageUploadResponse]) {
    self.uploadImages = uploadImages
  }
}
