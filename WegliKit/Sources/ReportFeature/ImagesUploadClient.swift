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
  static func live(
    wegliService: WegliAPIService = .live(),
    googleUploadService: GoogleUploadService = .live()
  ) -> Self {
    Self(
      uploadImages: { requests in
        return .task {
          do {
            return try await withThrowingTaskGroup(of: ImageUploadResponse.self, body: { group in
              for request in requests {
                group.addTask {
                  let response = try await wegliService.upload(request)
                  
                  guard let directUploadURL = URL(string: response.directUpload.url) else {
                    return response
                  }
                  let directUploadURLComponents = URLComponents(
                    url: directUploadURL,
                    resolvingAgainstBaseURL: false
                  )
                  
                  // wait until direct upload to gcloud is finished
                  try await googleUploadService.upload(
                    directUploadURLComponents?.url,
                    directUploadURLComponents?.queryItems,
                    request.imageData,
                    response.directUpload.headers
                  )
                  
                  return response
                }
              }
              var results: [ImageUploadResponse] = []
              for try await result in group {
                results.append(result)
              }
              return .success(results)
            })
          } catch {
            debugPrint(error)
            if let networkRequestError = error as? NetworkRequestError {
              return .failure(
                NSError(
                  domain: networkRequestError.errorDescription ?? networkRequestError.localizedDescription,
                  code: -1
                )
              )
            } else {
              return .failure(NSError(domain: "ImageUploader", code: -1))
            }
          }
        }
      }
    )
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
