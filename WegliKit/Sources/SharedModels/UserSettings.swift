import Foundation

public struct UserSettings: Equatable, Codable {
  public var showsAllTextRecognitionSettings = false

  public init(showsAllTextRecognitionSettings: Bool = false) {
    self.showsAllTextRecognitionSettings = showsAllTextRecognitionSettings
  }
}
