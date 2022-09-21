import Foundation

public extension ImagesUploadClient {
  static let noop = Self(
    uploadImages: { _ in [] }
  )
}
