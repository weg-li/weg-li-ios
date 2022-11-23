// Created for weg-li in 2021.

import ComposableArchitecture
import ContactFeature
import FileClient
import XCTest

@MainActor
final class ContactStoreTests: XCTestCase {
  func test_changeFirstName_shouldUpdateState() async {
    let didSaveContact = ActorIsolated(false)
    
    var fileClient = FileClient.noop
    fileClient.save = { @Sendable _, _ in
      await didSaveContact.setValue(true)
      return ()
    }
    
    let store = TestStore(
      initialState: ContactViewDomain.State.preview,
      reducer: ContactViewDomain()
    )
    store.dependencies.fileClient = fileClient
    let clock = TestClock()
    store.dependencies.continuousClock = clock
    
    let newFirstName = "Bob"
    await store.send(.contact(.set(\.$firstName, newFirstName))) {
      $0.contact.firstName = newFirstName
    }
    await clock.advance(by: .seconds(0.5))
    await didSaveContact.withValue { XCTAssertTrue($0) }
    await store.finish()
  }
  
  func test_changeName_shouldUpdateState() async {
    let store = TestStore(
      initialState: ContactViewDomain.State.preview,
      reducer: ContactViewDomain()
    )
    store.dependencies.fileClient.save = { @Sendable _, _ in () }
    store.dependencies.continuousClock = ImmediateClock()

    let newName = "Ross"
    await store.send(.contact(.set(\.$name, newName))) {
      $0.contact.name = newName
    }
    // set empty name
    await store.send(.contact(.set(\.$name, ""))) {
      $0.contact.name = ""
    }
    await store.finish()
  }

  func test_changePhone_shouldUpdateState() async {
    let store = TestStore(
      initialState: ContactViewDomain.State.preview,
      reducer: ContactViewDomain()
    )
    store.dependencies.fileClient.save = { @Sendable _, _ in () }
    store.dependencies.continuousClock = ImmediateClock()

    let newPhone = "0301234"
    await store.send(.contact(.set(\.$phone, newPhone))) {
      $0.contact.phone = newPhone
    }
    await store.finish()
  }

  func test_changeStreet_shouldUpdateState() async {
    let store = TestStore(
      initialState: ContactViewDomain.State.preview,
      reducer: ContactViewDomain()
    )
    store.dependencies.fileClient.save = { @Sendable _, _ in () }
    store.dependencies.continuousClock = ImmediateClock()

    let newStreet = "Bob's street"
    await store.send(.contact(.set(\.address.$street, newStreet))) {
      $0.contact.address.street = newStreet
    }
    await store.finish()
  }

  func test_changeCity_shouldUpdateState() async {
    let store = TestStore(
      initialState: ContactViewDomain.State.preview,
      reducer: ContactViewDomain()
    )
    store.dependencies.fileClient.save = { @Sendable _, _ in () }
    store.dependencies.continuousClock = ImmediateClock()

    let newCity = "Bob's city"
    await store.send(.contact(.set(\.address.$city, newCity))) {
      $0.contact.address.city = newCity
    }
    await store.finish()
  }

  func test_changePostalCode_shouldUpdateState() async {
    let store = TestStore(
      initialState: ContactViewDomain.State.preview,
      reducer: ContactViewDomain()
    )
    store.dependencies.fileClient.save = { @Sendable _, _ in () }
    store.dependencies.continuousClock = ImmediateClock()

    let newPostalCode = "55500"
    await store.send(.contact(.set(\.address.$postalCode, newPostalCode))) {
      $0.contact.address.postalCode = newPostalCode
    }
    await store.finish()
  }

  func test_changeDateOfBirth_shouldUpdateState() async {
    let store = TestStore(
      initialState: ContactViewDomain.State.preview,
      reducer: ContactViewDomain()
    )
    store.dependencies.fileClient.save = { @Sendable _, _ in () }
    store.dependencies.continuousClock = ImmediateClock()

    let newValue = "01.01.2992"
    await store.send(.contact(.set(\.$dateOfBirth, newValue))) {
      $0.contact.dateOfBirth = newValue
    }
    await store.finish()
  }

  func test_changeAddressAddition_shouldUpdateState() async {
    let store = TestStore(
      initialState: ContactViewDomain.State.preview,
      reducer: ContactViewDomain()
    )
    store.dependencies.fileClient.save = { @Sendable _, _ in () }
    store.dependencies.continuousClock = ImmediateClock()

    let newValue = "Hinterhaus"
    await store.send(.contact(.set(\.address.$addition, newValue))) {
      $0.contact.address.addition = newValue
    }
    await store.finish()
  }

  func test_setEmptyValues_shouldInvalidContact() async {
    let store = TestStore(
      initialState: ContactViewDomain.State.preview,
      reducer: ContactViewDomain()
    )
    store.dependencies.fileClient.save = { @Sendable _, _ in () }
    store.dependencies.continuousClock = ImmediateClock()
    
    await store.send(.contact(.set(\.address.$postalCode, ""))) {
      $0.contact.address.postalCode = ""
    }
    await store.send(.contact(.set(\.$name, ""))) {
      $0.contact.name = ""

      XCTAssertFalse($0.contact.isValid)
    }
    
    await store.finish()
  }

  func test_resetData_ButtonTap_PresentAnAlert() {
    let store = TestStore(
      initialState: ContactViewDomain.State.preview,
      reducer: ContactViewDomain()
    )

    store.send(.onResetContactDataButtonTapped) {
      $0.alert = .resetContactDataAlert
    }
  }

  func test_resetData_ConfirmButtonTap_shouldResetTheState_andDismissAlert() {
    let store = TestStore(
      initialState: ContactViewDomain.State.preview,
      reducer: ContactViewDomain()
    )

    store.send(.onResetContactConfirmButtonTapped) {
      $0 = .empty
    }
    store.receive(.dismissAlert)
  }
}
