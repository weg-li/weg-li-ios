import ApiClient
import ComposableArchitecture
import Foundation
import SharedModels

public extension ImagesUploadClient {
  static func live(
    wegliService: WegliAPIService = .live(),
    googleUploadService: GoogleUploadService = .live()
  ) -> Self {
    Self(
      uploadImages: { requests in
        .task {
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
