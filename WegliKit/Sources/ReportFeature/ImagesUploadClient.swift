import ApiClient
import ComposableArchitecture
import CryptoKit
import Foundation
import SharedModels
import UIKit

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
