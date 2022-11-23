import ApiClient
import Dependencies
import Foundation
import SharedModels

extension DependencyValues {
  public var imagesUploadClient: ImagesUploadClient {
    get { self[ImagesUploadClient.self] }
    set { self[ImagesUploadClient.self] = newValue }
  }
}


// MARK: Client interface


public struct ImagesUploadClient {
  public var uploadImages: ([PickerImageResult]) async throws -> [ImageUploadResponse]
  
  public init(uploadImages: @escaping ([PickerImageResult]) async throws -> [ImageUploadResponse]) {
    self.uploadImages = uploadImages
  }
}
