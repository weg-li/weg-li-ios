import ComposableArchitecture
import SharedModels
import SwiftUI
import Vision

public struct TextItem: Identifiable, Hashable {
  public var id: String = UUID().uuidString
  public var text = ""
  
  public init(id: String, text: String) {
    self.id = id
    self.text = text
  }
}

public struct TextRecognitionClient {
  public var recognizeText: (PickerImageResult) async throws -> [TextItem]
  
  public init(recognizeText: @escaping (PickerImageResult) async throws -> [TextItem]) {
    self.recognizeText = recognizeText
  }
}

public extension TextRecognitionClient {
  static let live = Self(
    recognizeText: { image in
      guard let cgImage = image.asUIImage?.cgImage else {
        throw VisionError.missingCGImage
      }
      
      // Create a new image-request handler.
      let requestHandler = VNImageRequestHandler(cgImage: cgImage)
      
      let task = Task(priority: .userInitiated) {
        try await withCheckedThrowingContinuation { (cont: CheckedContinuation<[TextItem], Error>) in
          performRequest(with: cgImage, imageId: image.id) { request, error in
            if let error = error {
              cont.resume(throwing: error)
            } else {
              guard let observations = request.results as? [VNRecognizedTextObservation] else {
                cont.resume(throwing: VisionError(message: "No results"))
                return
              }
              
              let textItems = observations
                .compactMap { $0.topCandidates(1).first }
                .map { TextItem(id: image.id, text: $0.string) }
              
              cont.resume(returning: textItems)
            }
          }
        }
      }
      
      return try await task.value
    }
  )
}

private func performRequest(
  with image: CGImage,
  imageId: String,
  completion: @escaping VNRequestCompletionHandler
) {
  let newHandler = VNImageRequestHandler(cgImage: image)
  
  let newRequest = VNRecognizeTextRequest(completionHandler: completion)
  newRequest.recognitionLevel = .accurate
  newRequest.recognitionLanguages = ["de", "en"]
  
  do {
    try newHandler.perform([newRequest])
  } catch {
    completion(newRequest, error)
  }
}

public extension TextRecognitionClient {
  static let noop = Self(
    recognizeText: { _ in [] }
  )
}

public struct VisionError: Equatable, Error {
  public init(message: String = "") {
    self.message = message
  }
  
  public var message = ""
  
  public static let missingCGImage = Self(message: "Can not find cgImage for image")
}
