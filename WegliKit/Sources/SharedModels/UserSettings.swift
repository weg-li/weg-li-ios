import Foundation

public struct UserSettings: Equatable, Codable {
  public var alwaysSendNotice: Bool
  public var showsAllTextRecognitionSettings: Bool

  public init(
    showsAllTextRecognitionSettings: Bool = false,
    alwaysSendNotice: Bool = true
  ) {
    self.showsAllTextRecognitionSettings = showsAllTextRecognitionSettings
    self.alwaysSendNotice = alwaysSendNotice
  }
}
