// Created for weg-li in 2021.

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
    
    await store.send(.set(\.$selectedColor, 1)) { state in
      state.selectedColor = 1
      
      XCTAssertEqual(DescriptionDomain.colors[1].value, "Beige")
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
    
    await store.send(.set(\.$licensePlateNumber, "WEG-LI-101")) { state in
      state.licensePlateNumber = "WEG-LI-101"
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
    
    await store.send(.set(\.$selectedDuration, 1)) { state in
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
    
    await store.send(.set(\.$licensePlateNumber, "WEG-LI-101")) { state in
      state.licensePlateNumber = "WEG-LI-101"
      
      XCTAssertTrue(state.isValid)
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
        values.continuousClock = ImmediateClock()
        values.fileClient = fileClient
      }
    )
    
    let charges = DescriptionDomain.charges.map {
      Charge(
        id: $0.key,
        text: $0.value,
        isFavorite: ["0"].contains($0.key),
        isSelected: false
      )
    }
    await store.send(.onAppear)
    await store.receive(.favoriteChargesLoaded(.success(["0"]))) {
      $0.chargeSelection.charges = IdentifiedArrayOf(uniqueElements: charges, id: \.id)
    }
    await store.receive(.chargeSelection(.sortFavoritedCharges)) {
      let sortedCharges = charges.sorted(by: { $0.isFavorite && !$1.isFavorite })
      $0.chargeSelection.charges = IdentifiedArrayOf(uniqueElements: sortedCharges, id: \.id)
    }
  }
}
