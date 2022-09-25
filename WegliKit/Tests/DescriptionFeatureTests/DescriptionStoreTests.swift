// Created for weg-li in 2021.

import Combine
import ComposableArchitecture
import DescriptionFeature
import FileClient
import XCTest

@MainActor
final class DescriptionStoreTests: XCTestCase {
  let brand: CarBrand = .init("Opel")
  
  func test_setCarColor_shouldUpdateState() {
    let store = TestStore(
      initialState: DescriptionState(),
      reducer: descriptionReducer,
      environment: DescriptionEnvironment(backgroundQueue: .failing)
    )
    
    store.send(.setColor(1)) { state in
      state.selectedColor = 1
      
      XCTAssertEqual(DescriptionState.colors[1].value, "Beige")
    }
  }
  
  func test_setCarType_shouldUpdateState() {
    let store = TestStore(
      initialState: DescriptionState(selectedColor: 1),
      reducer: descriptionReducer,
      environment: DescriptionEnvironment(backgroundQueue: .failing)
    )
    
    store.send(.setBrand(brand)) { state in
      state.selectedBrand = self.brand
    }
  }
  
  func test_setCarLicensePlate_shouldUpdateState() {
    let store = TestStore(
      initialState: DescriptionState(
        licensePlateNumber: "",
        selectedColor: 1,
        selectedBrand: brand
      ),
      reducer: descriptionReducer,
      environment: DescriptionEnvironment(backgroundQueue: .failing)
    )
    
    store.send(.setLicensePlateNumber("WEG-LI-101")) { state in
      state.licensePlateNumber = "WEG-LI-101"
    }
  }
  
  func test_selectCharge_shouldUpdateState() {
    let store = TestStore(
      initialState: DescriptionState(
        licensePlateNumber: "",
        selectedColor: 1,
        selectedBrand: brand
      ),
      reducer: descriptionReducer,
      environment: DescriptionEnvironment(backgroundQueue: .failing)
    )
    
    let testCharge = Charge(id: "1", text: "2", isFavorite: false, isSelected: true)
    store.send(.setCharge(testCharge)) { state in
      state.selectedCharge = testCharge
    }
  }
  
  func test_selectDuration_shouldUpdateState() {
    let store = TestStore(
      initialState: DescriptionState(
        licensePlateNumber: "",
        selectedColor: 1,
        selectedBrand: brand
      ),
      reducer: descriptionReducer,
      environment: DescriptionEnvironment(backgroundQueue: .failing)
    )
    
    store.send(.setDuration(1)) { state in
      state.selectedDuration = 1
    }
  }
  
  func test_setCarLicensePlate_shouldUpdateState_andSetItValid() {
    let store = TestStore(
      initialState: DescriptionState(
        licensePlateNumber: "",
        selectedColor: 1,
        selectedBrand: brand,
        selectedDuration: 3,
        selectedCharge: .init(id: "12", text: "213", isFavorite: false, isSelected: false),
        blockedOthers: false
      ),
      reducer: descriptionReducer,
      environment: DescriptionEnvironment(backgroundQueue: .failing)
    )
    
    store.send(.setLicensePlateNumber("WEG-LI-101")) { state in
      state.licensePlateNumber = "WEG-LI-101"
      
      XCTAssertTrue(state.isValid)
    }
  }
  
  func test_actionSetChargeTypeSearchText_shouldUpdateCharges() {
    let state = DescriptionState(
      licensePlateNumber: "",
      selectedColor: 1,
      selectedBrand: brand
    )
    
    let store = TestStore(
      initialState: state,
      reducer: descriptionReducer,
      environment: DescriptionEnvironment(
        mainQueue: .immediate,
        backgroundQueue: .immediate,
        fileClient: .noop
      )
    )
    
    store.send(.setChargeTypeSearchText("query")) {
      $0.chargeTypeSearchText = "query"
    }
  }
  
  func test_onAppear_shouldUpdateCharges() {
    var fileClient = FileClient.noop
    fileClient.load = { _ in
      .init(
        value: try! JSONEncoder().encode(["0"])
      )
    }
    
    let state = DescriptionState(
      licensePlateNumber: "",
      selectedColor: 1,
      selectedBrand: brand
    )
    
    let store = TestStore(
      initialState: state,
      reducer: descriptionReducer,
      environment: DescriptionEnvironment(
        mainQueue: .immediate,
        backgroundQueue: .immediate,
        fileClient: fileClient
      )
    )
    
    let charges = DescriptionState.charges.map {
      Charge(
        id: $0.key,
        text: $0.value,
        isFavorite: ["0"].contains($0.key),
        isSelected: false
      )
    }
    store.send(.onAppear)
    store.receive(.favoriteChargesLoaded(.success(["0"]))) {
      $0.charges = IdentifiedArrayOf(uniqueElements: charges, id: \.id)
    }
    store.receive(.sortFavoritedCharges) {
      let sortedCharges = charges.sorted(by: { $0.isFavorite && !$1.isFavorite })
      $0.charges = IdentifiedArrayOf(uniqueElements: sortedCharges, id: \.id)
    }
  }
  
  func test_actionToggleChargeFavorite() {
    var didWriteFiles = false
    var fileClient = FileClient.noop
    fileClient.save = { fileName, _ in
      didWriteFiles = fileName == "favorite-charge-Ids"
      return .none
    }
    
    var state = DescriptionState(
      licensePlateNumber: "",
      selectedColor: 1,
      selectedBrand: brand
    )
    let charge1 = Charge(id: "1", text: "Text", isFavorite: false, isSelected: false)
    let charge2 = Charge(id: "2", text: "Text", isFavorite: false, isSelected: false)
    
    state.charges = [charge1, charge2]
    
    let store = TestStore(
      initialState: state,
      reducer: descriptionReducer,
      environment: DescriptionEnvironment(
        mainQueue: .immediate,
        backgroundQueue: .immediate,
        fileClient: fileClient
      )
    )
    
    store.send(.toggleChargeFavorite(charge2)) {
      $0.charges = [
        charge1,
        Charge(id: "2", text: "Text", isFavorite: true, isSelected: false)
      ]
    }
    store.receive(.sortFavoritedCharges) {
      $0.charges = [
        Charge(id: "2", text: "Text", isFavorite: true, isSelected: false),
        charge1
      ]
    }
    XCTAssertTrue(didWriteFiles)
  }
}
