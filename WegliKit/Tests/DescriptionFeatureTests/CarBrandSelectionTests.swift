import ComposableArchitecture
import DescriptionFeature
import FileClient
import XCTest

@MainActor
final class CarBrandSelectionTests: XCTestCase {
  func test_setCarType_shouldUpdateState() async {
    let store = TestStore(
      initialState: CarBrandSelection.State(),
      reducer: CarBrandSelection()
    )
    
    let brand: CarBrand = .init("Audi")
    await store.send(.setBrand(brand)) { state in
      state.selectedBrand = brand
    }
  }
  
  func test_actionSetBrandSearchText_shouldSetQuery() async {
    let store = TestStore(
      initialState: CarBrandSelection.State(),
      reducer: CarBrandSelection()
    )
    
    await store.send(.set(\.$carBrandSearchText, "query")) {
      $0.carBrandSearchText = "query"
    }
  }
}
