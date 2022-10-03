import ApiClient
import Foundation
import SharedModels

public struct ImagesUploadClient {
  public var uploadImages: ([PickerImageResult]) async throws -> [ImageUploadResponse]
  
  public init(uploadImages: @escaping ([PickerImageResult]) async throws -> [ImageUploadResponse]) {
    self.uploadImages = uploadImages
  }
}
