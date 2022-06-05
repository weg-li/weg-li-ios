import Foundation

public struct UserSettings: Equatable, Codable {
  public var showsAllTextRecognitionSettings: Bool

  public init(showsAllTextRecognitionSettings: Bool = false) {
    self.showsAllTextRecognitionSettings = showsAllTextRecognitionSettings
  }
}
