import ApiClient
import ComposableArchitecture
import Foundation
import SharedModels

public struct ImagesUploadClient {
  public var uploadImages: ([UploadImageRequest]) -> Effect<Result<[ImageUploadResponse], NSError>, Never>
  
  public init(uploadImages: @escaping ([UploadImageRequest]) -> Effect<Result<[ImageUploadResponse], NSError>, Never>) {
    self.uploadImages = uploadImages
  }
}
