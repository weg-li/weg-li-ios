import AppFeature
import DescriptionFeature
import ReportFeature
import SharedModels
import SnapshotTesting
import SwiftUI
import XCTest

let appStoreViewConfigs: [String: SnapshotConfig] = [
  "iPhone_5_5": .init(adaptiveSize: .medium, deviceState: .phone, viewImageConfig: .iPhone8Plus),
  "iPhone_6_5": .init(adaptiveSize: .large, deviceState: .phone, viewImageConfig: .iPhoneXsMax),
  "iPad_12_9": .init(
    adaptiveSize: .large, deviceState: .pad, viewImageConfig: .iPadPro12_9(.landscape)
  )
]

class AppStoreConnectScreenshots: XCTestCase {
  override static func setUp() {
    super.setUp()
    SnapshotTesting.diffTool = "ksdiff"
  }

  override func setUpWithError() throws {
    try super.setUpWithError()
    isRecording = true
  }

  override func tearDown() {
    isRecording = false
    super.tearDown()
  }
  
  func test_AppViewScreenShot() {
    let appState = AppState(
      settings: .init(contact: .preview),
      reports: [
        .preview
      ],
      showReportWizard: false
    )
    let view = AppView(
      store: .init(
        initialState: appState,
        reducer: .empty,
        environment: ()
      )
    )
    
    assertAppStoreSnapshots(
      view: AnyView(view),
      description: { Text("Behalte deine Anzeigen im Blick").foregroundColor(Color.black.opacity(0.4)) },
      backgroundColor: .wegliBlue,
      colorScheme: .light
    )
  }
  
  func test_EditDescriptionViewScreenshot() {
    let view = EditDescriptionView(
      store: .init(
        initialState: ReportState.preview.description,
        reducer: .empty,
        environment: ()
      )
    )
    
    assertAppStoreSnapshots(
      view: AnyView(NavigationView(content: { view }).navigationViewStyle(StackNavigationViewStyle())),
      description: { Text("Erstelle eine Anzeige mit Hilfe der App") },
      backgroundColor: .wegliBlue,
      colorScheme: .light
    )
  }
}
