import ApiClient
import Foundation
import SharedModels

public extension ImagesUploadClient {
  static func live(
    wegliService: WegliAPIService = .live(),
    googleUploadService: GoogleUploadService = .live()
  ) -> Self {
    Self(
      uploadImages: { results in
        try await withThrowingTaskGroup(of: ImageUploadResponse.self) { group in
          for result in results {
            group.addTask {
              let uploadResponse = try await wegliService.upload(result)
              
              guard let directUploadURL = URL(string: uploadResponse.directUpload.url) else {
                return uploadResponse
              }
              let directUploadURLComponents = URLComponents(
                url: directUploadURL,
                resolvingAgainstBaseURL: false
              )
              
              // wait until direct upload to gcloud is finished
              try await googleUploadService.upload(
                directUploadURLComponents?.url,
                directUploadURLComponents?.queryItems,
                result.jpegData,
                uploadResponse.directUpload.headers
              )
              
              return uploadResponse
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
