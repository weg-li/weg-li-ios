import ComposableArchitecture

public extension ImageConverter {
  static let noop = Self(
      downsample: { _, _, _ in .none }
  )
}
