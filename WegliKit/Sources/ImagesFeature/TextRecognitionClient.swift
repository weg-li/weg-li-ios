import ComposableArchitecture
import SharedModels
import SwiftUI
import Vision
import XCTestDynamicOverlay

extension DependencyValues {
  public var textRecognitionClient: TextRecognitionClient {
    get { self[TextRecognitionClient.self] }
    set { self[TextRecognitionClient.self] = newValue }
  }
}

// MARK: Client interface

public struct TextRecognitionClient {
  public var recognizeText: (PickerImageResult) async throws -> [TextItem]
  
  public init(recognizeText: @escaping (PickerImageResult) async throws -> [TextItem]) {
    self.recognizeText = recognizeText
  }
}

extension TextRecognitionClient: DependencyKey {
  public static var liveValue: TextRecognitionClient = live
  
  static let live = Self(
    recognizeText: { image in
      guard let imageUrl = image.imageUrl else {
        throw VisionError.missingCGImage
      }
            
      let task = Task(priority: .userInitiated) {
        try await withCheckedThrowingContinuation { (cont: CheckedContinuation<[TextItem], Error>) in
          performRequest(imageUrl: imageUrl, imageId: image.id) { request, error in
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
  imageUrl: URL,
  imageId: String,
  completion: @escaping VNRequestCompletionHandler
) {
  let newHandler = VNImageRequestHandler(url: imageUrl)
  
  let newRequest = VNRecognizeTextRequest(completionHandler: completion)
  newRequest.recognitionLevel = .accurate
  newRequest.recognitionLanguages = ["de", "en"]
  
  do {
    try newHandler.perform([newRequest])
  } catch {
    completion(newRequest, error)
  }
}

extension TextRecognitionClient: TestDependencyKey {
  public static let noop = Self(
    recognizeText: { _ in [] }
  )
  
  public static var testValue: TextRecognitionClient = Self(
    recognizeText: unimplemented("\(Self.self).recognizeText", placeholder: [])
  )
}

// MARK: Helper
public struct TextItem: Identifiable, Hashable {
  public var id: String = UUID().uuidString
  public var text = ""
  
  public init(id: String, text: String) {
    self.id = id
    self.text = text
  }
}

public struct VisionError: Equatable, Error {
  public init(message: String = "") {
    self.message = message
  }
  
  public var message = ""
  
  public static let missingCGImage = Self(message: "Can not find cgImage for image")
}
