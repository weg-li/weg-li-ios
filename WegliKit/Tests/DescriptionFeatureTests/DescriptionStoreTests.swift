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
}
