import ApiClient
import ComposableArchitecture
import CryptoKit
import Foundation
import SharedModels
import UIKit

public struct ImagesUploadClient {
  var uploadImages: ([UploadImageRequest]) -> Effect<Result<[ImageUploadResponse], NSError>, Never>
  
  public init(uploadImages: @escaping ([UploadImageRequest]) -> Effect<Result<[ImageUploadResponse], NSError>, Never>) {
    self.uploadImages = uploadImages
  }
}

public extension ImagesUploadClient {
  static func live(apiClient: APIClient = .live) -> Self {
    Self(
      uploadImages: { requests in
        return .task {
          do {
            return try await withThrowingTaskGroup(of: ImageUploadResponse.self, body: { group in
              for request in requests {
                group.addTask {
                  let response = try await apiClient.dispatch(request)
                  return try JSONDecoder.noticeDecoder.decode(ImageUploadResponse.self, from: response)
                }
              }
              var results: [ImageUploadResponse] = []
              for try await result in group {
                results.append(result)
              }
              return .success(results)
            })
          } catch {
            debugPrint(error.localizedDescription)
            return .failure(NSError(domain: "ImageUploader", code: -1))
          }
        }
      }
    )
  }
}

public struct ImageUploadResponse: Codable, Equatable {
  public let id: Int
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
    public init(url: String) {
      self.url = url
    }
    
    public let url: String
  }
}

struct ImageUploadTask {
  let id: UUID
  let input: UploadImageRequest
  
  init(input: UploadImageRequest, id: UUID = UUID()) {
    self.id = id
    self.input = input
  }
  
  func run() async -> Result<ImageUploadResponse, Error> {
    do {
      let request = try input.makeRequest()
      let (data, _) = try await URLSession.shared.data(for: request)
      let result = try JSONDecoder.noticeDecoder.decode(ImageUploadResponse.self, from: data)
      return .success(result)
    } catch {
      return .failure(error)
    }
  }
}
