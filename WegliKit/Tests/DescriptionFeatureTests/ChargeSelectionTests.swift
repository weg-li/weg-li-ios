import ComposableArchitecture
import DescriptionFeature
import FileClient
import XCTest

@MainActor
final class ChargeSelectionTests: XCTestCase {
  func test_selectCharge_shouldUpdateState() async {
    let store = TestStore(
      initialState: ChargeSelection.State(),
      reducer: ChargeSelection()
    )
    
    let testCharge = Charge(id: "1", text: "2", isFavorite: false, isSelected: true)
    await store.send(.setCharge(testCharge)) { state in
      state.selectedCharge = testCharge
    }
  }
  
  func test_actionSetChargeTypeSearchText_shouldUpdateCharges() async {
    let state = ChargeSelection.State()
    
    let store = TestStore(
      initialState: state,
      reducer: ChargeSelection(),
      prepareDependencies: { values in
        values.continuousClock = ImmediateClock()
        values.fileClient = .noop
      }
    )
    
    await store.send(.setChargeTypeSearchText("query")) {
      $0.chargeTypeSearchText = "query"
    }
  }

  func test_actionToggleChargeFavorite() async {
    let clock = TestClock()
    
    let didWriteFiles = ActorIsolated(false)
    var fileClient = FileClient.noop
    fileClient.save = { @Sendable fileName, _ in
      await didWriteFiles.setValue(true)
      return ()
    }
    
    var state = ChargeSelection.State()
    let charge1 = Charge(id: "1", text: "Text", isFavorite: false, isSelected: false)
    let charge2 = Charge(id: "2", text: "Text", isFavorite: false, isSelected: false)
    state.charges = [charge1, charge2]
    
    let store = TestStore(
      initialState: state,
      reducer: ChargeSelection(),
      prepareDependencies: { values in
        values.continuousClock = clock
        values.fileClient = fileClient
      }
    )
    
    await store.send(.toggleChargeFavorite(charge2)) {
      $0.charges = [
        charge1,
        Charge(id: "2", text: "Text", isFavorite: true, isSelected: false)
      ]
    }
    
    await clock.advance(by: .milliseconds(1001))
    await store.receive(.sortFavoritedCharges) {
      $0.charges = [
        Charge(id: "2", text: "Text", isFavorite: true, isSelected: false),
        charge1
      ]
    }
  }
}
