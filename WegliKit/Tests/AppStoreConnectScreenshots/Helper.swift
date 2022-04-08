import SwiftUI
import SnapshotTesting

func assertAppStoreSnapshots<Description, SnapshotContent>(
  view: SnapshotContent,
  @ViewBuilder description: @escaping () -> Description,
  backgroundColor: Color,
  colorScheme: ColorScheme,
  precision: Float = 1,
  file: StaticString = #file,
  testName: String = #function,
  line: UInt = #line,
  afterMilliSecondsDelay delay: Int = 0
)
where
  SnapshotContent: View,
  Description: View
{
  for (name, config) in appStoreViewConfigs {
    var transaction = Transaction(animation: nil)
    transaction.disablesAnimations = true
    withTransaction(transaction) {
      assertSnapshot(
        matching: AppStorePreview(
          .image(layout: .device(config: config.viewImageConfig)),
          description: description,
          backgroundColor: backgroundColor
        ) {
          view
            .environment(\.adaptiveSize, config.adaptiveSize)
            .environment(\.colorScheme, colorScheme)
            .environment(\.deviceState, config.deviceState)
        }
          .environment(\.colorScheme, colorScheme)
          .environment(\.deviceState, config.deviceState),
        as: .image(precision: precision, layout: .device(config: config.viewImageConfig)),
        named: name,
        file: file,
        testName: testName,
        line: line
      )
    }
  }
}

extension EnvironmentValues {
  public var adaptiveSize: AdaptiveSize {
    get { self[AdaptiveSizeKey.self] }
    set { self[AdaptiveSizeKey.self] = newValue }
  }
}

private struct AdaptiveSizeKey: EnvironmentKey {
  static var defaultValue: AdaptiveSize {
    switch UIScreen.main.bounds.width {
    case ..<375:
      return .small
    case ..<428:
      return .medium
    default:
      return .large
    }
  }
}


struct SnapshotConfig {
  let adaptiveSize: AdaptiveSize
  let deviceState: DeviceState
  let viewImageConfig: ViewImageConfig
}

public enum AdaptiveSize {
  case small
  case medium
  case large

  public func pad(_ other: CGFloat, by scale: CGFloat = 1) -> CGFloat {
    self.padding * scale + other
  }

  public var padding: CGFloat {
    switch self {
    case .small:
      return 0
    case .medium:
      return 4
    case .large:
      return 8
    }
  }
}

public struct DeviceState {
  public var idiom: UIUserInterfaceIdiom
  public var orientation: UIDeviceOrientation
  public var previousOrientation: UIDeviceOrientation

  public static let `default` = Self(
    idiom: UIDevice.current.userInterfaceIdiom,
    orientation: UIDevice.current.orientation,
    previousOrientation: UIDevice.current.orientation
  )

  public var isPad: Bool {
    self.idiom == .pad
  }

  public var isPhone: Bool {
    self.idiom == .phone
  }

  #if DEBUG
    public static let phone = Self(
      idiom: .phone,
      orientation: .portrait,
      previousOrientation: .portrait
    )

    public static let pad = Self(
      idiom: .pad,
      orientation: .landscapeLeft,
      previousOrientation: .landscapeLeft
    )
  #endif
}


public struct DeviceStateModifier: ViewModifier {
  @State var state: DeviceState = .default

  public init() {
  }

  public func body(content: Content) -> some View {
    content
      .onAppear()
      .onReceive(
        NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)
      ) { _ in
        self.state.previousOrientation = self.state.orientation
        self.state.orientation = UIDevice.current.orientation
      }
      .environment(\.deviceState, self.state)
  }
}

extension EnvironmentValues {
  public var deviceState: DeviceState {
    get { self[DeviceStateKey.self] }
    set { self[DeviceStateKey.self] = newValue }
  }
}

private struct DeviceStateKey: EnvironmentKey {
  static var defaultValue: DeviceState {
    .default
  }
}
