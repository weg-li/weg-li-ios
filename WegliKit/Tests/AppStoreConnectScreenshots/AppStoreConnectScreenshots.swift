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
  
  func test_noticesTab() {
    var appState = AppState(
      settings: .init(
        accountSettingsState: .init(accountSettings: .init(apiToken: "")),
        contact: .preview,
        userSettings: .init()
      ),
      notices: .results([.init(.preview), .report2])
    )
    appState.selectedTab = .notices
    let view = AppView(
      store: .init(
        initialState: appState,
        reducer: .empty,
        environment: ()
      )
    )
    
    assertAppStoreSnapshots(
      view: AnyView(view),
      description: { Text("Behalte deine Meldungen im Blick").foregroundColor(Color.black.opacity(0.4)) },
      backgroundColor: .wegliBlue,
      colorScheme: .light
    )
  }
  
  func test_newNotice() {
    var appState = AppState(
      settings: .init(
        accountSettingsState: .init(accountSettings: .init(apiToken: "")),
        contact: .preview,
        userSettings: .init()
      ),
      notices: .results([.init(.preview), .report2])
    )
    appState.selectedTab = .notice
    appState.reportDraft = .preview
    appState.reportDraft.images = .init(
      alert: nil,
      showImagePicker: false,
      storedPhotos: [PickerImageResult(id: "1", uiImage: UIImage(named: "homer", in: .module, with: nil)!, imageUrl: nil)],
      coordinateFromImagePicker: nil,
      dateFromImagePicker: nil
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
      description: { Text("Erstelle eine Meldung mit Hilfe der App").foregroundColor(Color.black.opacity(0.4)) },
      backgroundColor: .wegliBlue,
      colorScheme: .light
    )
  }
  
  func test_EditDescriptionViewScreenshot() {
    let view = EditDescriptionView(
      store: .init(
        initialState: ReportDomain.State.preview.description,
        reducer: .empty,
        environment: ()
      )
    )
    
    assertAppStoreSnapshots(
      view: AnyView(NavigationView(content: { view }).navigationViewStyle(.stack)),
      description: { Text("Beschreibe die Meldung") },
      backgroundColor: .wegliBlue,
      colorScheme: .light
    )
  }
}

extension Notice {
  static var report2: Notice {
    let report = ReportDomain.State(
      uuid: UUID.init,
      images: .init(
        showImagePicker: false,
        storedPhotos: [PickerImageResult(uiImage: UIImage(named: "homer", in: .module, with: nil)!)] // swiftlint:disable:this force_unwrapping
      ),
      contactState: .preview,
      district: District(
        name: "Berlin",
        zip: "12435",
        email: "mail@ba-berlin-treptow.de",
        latitude: 53.53,
        longitude: 13.13,
        personalEmail: true
      ),
      date: { Date(timeIntervalSince1970: 1_580_624_207) },
      description: .init(
        licensePlateNumber: "B-MX-231",
        selectedColor: 6,
        selectedBrand: .init("Ente"),
        selectedDuration: 2,
        selectedCharge: .init(id: "1", text: "Parken auf dem Radweg", isFavorite: true, isSelected: false),
        blockedOthers: true
      )
    )
    return .init(report)
  }
}
