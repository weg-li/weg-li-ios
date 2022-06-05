import ComposableArchitecture
import SharedModels
import SwiftUI
import Vision

public struct TextItem: Identifiable, Hashable {
  public var id: String = UUID().uuidString
  public var text: String = ""
  
  public init(id: String, text: String) {
    self.id = id
    self.text = text
  }
}

public struct TextRecognitionClient {
  public var recognizeText: (PickerImageResult) -> Effect<[TextItem], VisionError>
  
  public init(recognizeText: @escaping (PickerImageResult) -> Effect<[TextItem], VisionError>) {
    self.recognizeText = recognizeText
  }

  public func recognizeText(
    in image: PickerImageResult,
    on queue: AnySchedulerOf<DispatchQueue>
  ) -> Effect<[TextItem], VisionError> {
    recognizeText(image)
      .subscribe(on: queue)
      .eraseToEffect()
  }
}

public extension TextRecognitionClient {
  static let live = Self(
    recognizeText: { image in
      .future { callback in
        guard let cgImage = image.asUIImage?.cgImage else {
          callback(.failure(.missingCGImage))
          return
        }
          
        // Create a new image-request handler.
        let requestHandler = VNImageRequestHandler(cgImage: cgImage)
          
        // Create a new request to recognize text.
        let request = VNRecognizeTextRequest { request, _ in
          guard let observations = request.results as? [VNRecognizedTextObservation] else {
            callback(.failure(.init(message: "Observations can not be casted to VNRecognizedTextObservation")))
            return
          }
          let textItems = observations
            .compactMap { $0.topCandidates(1).first }
            .map { TextItem(id: image.id, text: $0.string) }
          callback(.success(textItems))
        }
          
        request.recognitionLanguages = ["de", "en"]
        request.recognitionLevel = .accurate
          
        do {
          try requestHandler.perform([request])
        } catch {
          callback(.failure(.init(message: error.localizedDescription)))
        }
      }
    }
  )
}

public extension TextRecognitionClient {
  static let noop = Self(
    recognizeText: { _ in .none }
  )
}

public struct VisionError: Equatable, Error {
  public init(message: String = "") {
    self.message = message
  }
  
  public var message = ""
  
  public static let missingCGImage = Self(message: "Can not find cgImage for image")
}
