import ApiClient
import Foundation
import SharedModels

public extension ImagesUploadClient {
  static func live(
    wegliService: WegliAPIService = .live(),
    googleUploadService: GoogleUploadService = .live()
  ) -> Self {
    Self(
      uploadImages: { requests in
        try await withThrowingTaskGroup(of: ImageUploadResponse.self) { group in
          for request in requests {
            group.addTask {
              let gcloudUploadResponse = try await wegliService.upload(request)
              
              guard let directUploadURL = URL(string: gcloudUploadResponse.directUpload.url) else {
                return gcloudUploadResponse
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
                gcloudUploadResponse.directUpload.headers
              )
              
              return gcloudUploadResponse
            }
          }
          
          var results: [ImageUploadResponse] = []
          for try await result in group {
            results.append(result)
          }
          return results
        }
      }
    )
  }
}
