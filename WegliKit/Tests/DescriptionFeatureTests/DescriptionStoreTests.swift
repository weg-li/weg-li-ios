// Created for weg-li in 2021.

import Combine
import ComposableArchitecture
import DescriptionFeature
import FileClient
import XCTest

@MainActor
final class DescriptionStoreTests: XCTestCase {
  let brand: CarBrand = .init("Opel")
  
  func test_setCarColor_shouldUpdateState() async {
    let store = TestStore(
      initialState: DescriptionDomain.State(),
      reducer: DescriptionDomain()
    )
    
    await store.send(.setColor(1)) { state in
      state.selectedColor = 1
      
      XCTAssertEqual(DescriptionDomain.State.colors[1].value, "Beige")
    }
  }
  
  func test_setCarType_shouldUpdateState() async {
    let store = TestStore(
      initialState: DescriptionDomain.State(selectedColor: 1),
      reducer: DescriptionDomain()
    )
    
    await store.send(.setBrand(brand)) { state in
      state.selectedBrand = self.brand
    }
  }
  
  func test_setCarLicensePlate_shouldUpdateState() async {
    let store = TestStore(
      initialState: DescriptionDomain.State(
        licensePlateNumber: "",
        selectedColor: 1,
        selectedBrand: brand
      ),
      reducer: DescriptionDomain()
    )
    
    await store.send(.setLicensePlateNumber("WEG-LI-101")) { state in
      state.licensePlateNumber = "WEG-LI-101"
    }
  }
  
  func test_selectCharge_shouldUpdateState() async {
    let store = TestStore(
      initialState: DescriptionDomain.State(
        licensePlateNumber: "",
        selectedColor: 1,
        selectedBrand: brand
      ),
      reducer: DescriptionDomain()
    )
    
    let testCharge = Charge(id: "1", text: "2", isFavorite: false, isSelected: true)
    await store.send(.setCharge(testCharge)) { state in
      state.selectedCharge = testCharge
    }
  }
  
  func test_selectDuration_shouldUpdateState() async {
    let store = TestStore(
      initialState: DescriptionDomain.State(
        licensePlateNumber: "",
        selectedColor: 1,
        selectedBrand: brand
      ),
      reducer: DescriptionDomain()
    )
    
    await store.send(.setDuration(1)) { state in
      state.selectedDuration = 1
    }
  }
  
  func test_setCarLicensePlate_shouldUpdateState_andSetItValid() async {
    let store = TestStore(
      initialState: DescriptionDomain.State(
        licensePlateNumber: "",
        selectedColor: 1,
        selectedBrand: brand,
        selectedDuration: 3,
        selectedCharge: .init(id: "12", text: "213", isFavorite: false, isSelected: false),
        blockedOthers: false
      ),
      reducer: DescriptionDomain()
    )
    
    await store.send(.setLicensePlateNumber("WEG-LI-101")) { state in
      state.licensePlateNumber = "WEG-LI-101"
      
      XCTAssertTrue(state.isValid)
    }
  }
  
  func test_actionSetChargeTypeSearchText_shouldUpdateCharges() async {
    let state = DescriptionDomain.State(
      licensePlateNumber: "",
      selectedColor: 1,
      selectedBrand: brand
    )
    
    let store = TestStore(
      initialState: state,
      reducer: DescriptionDomain(),
      prepareDependencies: { values in
        values.suspendingClock = ImmediateClock()
        values.fileClient = .noop
      }
    )
    
    await store.send(.setChargeTypeSearchText("query")) {
      $0.chargeTypeSearchText = "query"
    }
  }
  
  func test_onAppear_shouldUpdateCharges() async {
    var fileClient = FileClient.noop
    fileClient.load = { @Sendable _ in
      .init(
        try! JSONEncoder().encode(["0"])
      )
    }
    
    let state = DescriptionDomain.State(
      licensePlateNumber: "",
      selectedColor: 1,
      selectedBrand: brand
    )
    
    let store = TestStore(
      initialState: state,
      reducer: DescriptionDomain(),
      prepareDependencies: { values in
        values.suspendingClock = ImmediateClock()
        values.fileClient = fileClient
      }
    )
    
    let charges = DescriptionDomain.State.charges.map {
      Charge(
        id: $0.key,
        text: $0.value,
        isFavorite: ["0"].contains($0.key),
        isSelected: false
      )
    }
    await store.send(.onAppear)
    await store.receive(.favoriteChargesLoaded(.success(["0"]))) {
      $0.charges = IdentifiedArrayOf(uniqueElements: charges, id: \.id)
    }
    await store.receive(.sortFavoritedCharges) {
      let sortedCharges = charges.sorted(by: { $0.isFavorite && !$1.isFavorite })
      $0.charges = IdentifiedArrayOf(uniqueElements: sortedCharges, id: \.id)
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
    
    var state = DescriptionDomain.State(
      licensePlateNumber: "",
      selectedColor: 1,
      selectedBrand: brand
    )
    let charge1 = Charge(id: "1", text: "Text", isFavorite: false, isSelected: false)
    let charge2 = Charge(id: "2", text: "Text", isFavorite: false, isSelected: false)
    
    state.charges = [charge1, charge2]
    
    let store = TestStore(
      initialState: state,
      reducer: DescriptionDomain(),
      prepareDependencies: { values in
        values.suspendingClock = clock
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
