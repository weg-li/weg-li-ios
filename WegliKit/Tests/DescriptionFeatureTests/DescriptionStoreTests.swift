// Created for weg-li in 2021.

import ComposableArchitecture
import DescriptionFeature
import XCTest

class DescriptionStoreTests: XCTestCase {
  func test_setCarColor_shouldUpdateState() {
    let store = TestStore(
      initialState: DescriptionState(),
      reducer: descriptionReducer,
      environment: DescriptionEnvironment()
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
      environment: DescriptionEnvironment()
    )
    
    store.send(.setBrand(1)) { state in
      state.selectedBrand = 1
      
      XCTAssertEqual(DescriptionState.brands[1], "Abarth")
    }
  }
  
  func test_setCarLicensePlate_shouldUpdateState() {
    let store = TestStore(
      initialState: DescriptionState(
        licensePlateNumber: "",
        selectedColor: 1,
        selectedBrand: 1
      ),
      reducer: descriptionReducer,
      environment: DescriptionEnvironment()
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
        selectedBrand: 1
      ),
      reducer: descriptionReducer,
      environment: DescriptionEnvironment()
    )
    
    store.send(.setCharge(1)) { state in
      state.selectedType = 1
      
      XCTAssertEqual(DescriptionState.charges[1].value, "Parken an einer engen/unübersichtlichen Straßenstelle")
    }
  }
  
  func test_selectDuration_shouldUpdateState() {
    let store = TestStore(
      initialState: DescriptionState(
        licensePlateNumber: "",
        selectedColor: 1,
        selectedBrand: 1
      ),
      reducer: descriptionReducer,
      environment: DescriptionEnvironment()
    )
    
    store.send(.setDuraration(1)) { state in
      state.selectedDuration = 1
    }
  }
  
  func test_toggleBlockedOthers_shouldUpdateState() {
    let store = TestStore(
      initialState: DescriptionState(
        licensePlateNumber: "",
        selectedColor: 1,
        selectedBrand: 1
      ),
      reducer: descriptionReducer,
      environment: DescriptionEnvironment()
    )
    
    store.send(.toggleBlockedOthers) { state in
      state.blockedOthers = true
    }
    store.send(.toggleBlockedOthers) { state in
      state.blockedOthers = false
    }
  }
  
  func test_setCarLicensePlate_shouldUpdateState_andSetItValid() {
    let store = TestStore(
      initialState: DescriptionState(
        licensePlateNumber: "",
        selectedColor: 1,
        selectedBrand: 1
      ),
      reducer: descriptionReducer,
      environment: DescriptionEnvironment()
    )
    
    store.send(.setLicensePlateNumber("WEG-LI-101")) { state in
      state.licensePlateNumber = "WEG-LI-101"
      
      XCTAssertTrue(state.isValid)
    }
  }
}
