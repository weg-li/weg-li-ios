import Dependencies
import UIKit

extension FeedbackGeneratorClient: DependencyKey {
  public static let liveValue = {
    let generator = UINotificationFeedbackGenerator()
    let selectionGenerator = UISelectionFeedbackGenerator()
    return Self(
      prepare: { await generator.prepare() },
      notify: { await generator.notificationOccurred($0) },
      selectionChanged: { await selectionGenerator.selectionChanged() }
    )
  }()
}
