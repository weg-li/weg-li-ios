import Dependencies
import Foundation
import XCTestDynamicOverlay

extension ImagesUploadClient: TestDependencyKey {
  public static let noop = Self(
    uploadImages: { _ in [] }
  )
}
