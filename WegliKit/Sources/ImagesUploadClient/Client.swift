import ApiClient
import Dependencies
import DependenciesMacros
import Foundation
import SharedModels

extension DependencyValues {
  public var imagesUploadClient: ImagesUploadClient {
    get { self[ImagesUploadClient.self] }
    set { self[ImagesUploadClient.self] = newValue }
  }
}

// MARK: Client interface

@DependencyClient
public struct ImagesUploadClient {
  public var uploadImages: (_ results: [PickerImageResult]) async throws -> [ImageUploadResponse]
}
