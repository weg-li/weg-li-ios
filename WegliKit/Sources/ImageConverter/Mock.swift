import ComposableArchitecture

public extension ImageConverter {
  static let noop = Self(
      scale: { _ in .none },
      downsample: { _, _, _ in .none }
  )
}
