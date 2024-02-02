import ApiClient
import Dependencies
import Foundation
import SharedModels

extension ImagesUploadClient: DependencyKey {
  public static var liveValue: ImagesUploadClient = .live()
  
  static func live(
    wegliService: APIService = .liveValue,
    googleUploadService: GoogleUploadService = .liveValue
  ) -> Self {
    Self(
      uploadImages: {
        results in
        try await withThrowingTaskGroup(of: ImageUploadResponse.self) { group in
          for result in results {
            guard let imageData = result.jpegData else {
              continue
            }
            
            group.addTask {
              let uploadResponse = try await wegliService.upload(
                id: result.id,
                imageData: imageData
              )
              
              guard let directUploadURL = URL(string: uploadResponse.directUpload.url) else {
                return uploadResponse
              }
              
              // wait until direct upload to gcloud is finished
              try await googleUploadService.upload(
                url: directUploadURL,
                body: imageData,
                headers: uploadResponse.directUpload.headers
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
