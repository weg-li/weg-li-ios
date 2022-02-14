// Created for weg-li in 2021.

import ComposableArchitecture
import ContactFeature
import XCTest

class ContactStoreTests: XCTestCase {
  func test_changeFirstName_shouldUpdateState() {
    let store = TestStore(
      initialState: ContactState.preview,
      reducer: contactReducer,
      environment: ContactEnvironment()
    )
    
    let newFirstName = "Bob"
    store.send(.firstNameChanged(newFirstName)) {
      $0.contact.firstName = newFirstName
    }
  }
  
  func test_changeName_shouldUpdateState() {
    let store = TestStore(
      initialState: ContactState.preview,
      reducer: contactReducer,
      environment: ContactEnvironment()
    )
    
    let newName = "Ross"
    store.send(.lastNameChanged(newName)) {
      $0.contact.name = newName
    }
    // set empty name
    store.send(.lastNameChanged("")) {
      $0.contact.name = ""
    }
  }
  
  func test_changePhone_shouldUpdateState() {
    let store = TestStore(
      initialState: ContactState.preview,
      reducer: contactReducer,
      environment: ContactEnvironment()
    )
    
    let newPhone = "0301234"
    store.send(.phoneChanged(newPhone)) {
      $0.contact.phone = newPhone
    }
  }
  
  func test_changeStreet_shouldUpdateState() {
    let store = TestStore(
      initialState: ContactState.preview,
      reducer: contactReducer,
      environment: ContactEnvironment()
    )
    
    let newStreet = "Bob's street"
    store.send(.streetChanged(newStreet)) {
      $0.contact.address.street = newStreet
    }
  }
  
  func test_changeCity_shouldUpdateState() {
    let store = TestStore(
      initialState: ContactState.preview,
      reducer: contactReducer,
      environment: ContactEnvironment()
    )
    
    let newCity = "Bob's city"
    store.send(.townChanged(newCity)) {
      $0.contact.address.city = newCity
    }
  }
  
  func test_changePostalCode_shouldUpdateState() {
    let store = TestStore(
      initialState: ContactState.preview,
      reducer: contactReducer,
      environment: ContactEnvironment()
    )
    
    let newPostalCode = "55500"
    store.send(.zipCodeChanged(newPostalCode)) {
      $0.contact.address.postalCode = newPostalCode
    }
  }
  
  func test_changeDateOfBirth_shouldUpdateState() {
    let store = TestStore(
      initialState: ContactState.preview,
      reducer: contactReducer,
      environment: ContactEnvironment()
    )
    
    let newValue = "01.01.2992"
    store.send(.dateOfBirthChanged(newValue)) {
      $0.contact.dateOfBirth = newValue
    }
  }
  
  func test_changeAddressAddition_shouldUpdateState() {
    let store = TestStore(
      initialState: ContactState.preview,
      reducer: contactReducer,
      environment: ContactEnvironment()
    )
    
    let newValue = "Hinterhaus"
    store.send(.addressAdditionChanged(newValue)) {
      $0.contact.address.addition = newValue
    }
    
  }
  
  func test_setEmptyValues_shouldInvalidContact() {
    let store = TestStore(
      initialState: ContactState.preview,
      reducer: contactReducer,
      environment: ContactEnvironment()
    )
    
    store.send(.zipCodeChanged("")) {
      $0.contact.address.postalCode = ""
    }
    store.send(.lastNameChanged("")) {
      $0.contact.name = ""
      
      XCTAssertFalse($0.isValid)
    }
  }
  
  func test_resetData_ButtonTap_PresentAnAlert() {
    let store = TestStore(
      initialState: ContactState.preview,
      reducer: contactReducer,
      environment: ContactEnvironment()
    )
    
    store.send(.resetContactDataButtonTapped) {
      $0.alert = .resetContactDataAlert
    }
  }
  
  func test_resetData_ConfirmButtonTap_shouldResetTheState_andDismissAlert() {
    let store = TestStore(
      initialState: ContactState.preview,
      reducer: contactReducer,
      environment: ContactEnvironment()
    )
    
    store.send(.resetContactConfirmButtonTapped) {
      $0 = .empty
    }
    store.receive(.dismissAlert)
  }
}
