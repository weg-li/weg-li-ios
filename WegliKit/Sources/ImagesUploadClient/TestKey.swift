import Dependencies
import Foundation
import XCTestDynamicOverlay

extension ImagesUploadClient: TestDependencyKey {
  public static let noop = Self(
    uploadImages: { _ in [] }
  )
  
  public static let testValue: ImagesUploadClient = Self(
    uploadImages: unimplemented("\(Self.self).uploadImages", placeholder: [])
  )
}
