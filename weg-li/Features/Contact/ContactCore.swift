// Created for weg-li in 2021.

import ComposableArchitecture
import Contacts
import Foundation

struct ContactState: Equatable, Codable {
    struct Address: Equatable, Codable {
        var street: String = ""
        var postalCode: String = ""
        var city: String = ""
        var addition: String = ""
    }

    var firstName: String = ""
    var name: String = ""
    var address: Address = .init()
    var phone: String = ""
    var dateOfBirth: String = ""

    var alert: AlertState<ContactAction>?

    var isValid: Bool {
        [
            firstName,
            name,
            address.street,
            address.city
        ].allSatisfy { !$0.isEmpty }
            && address.postalCode.isNumeric
            && address.postalCode.count == 5
    }

    var humandReadableContact: String {
        var contact = "\(firstName) \(name)"
        if !phone.isEmpty {
            contact.append("\nTelefonnummer: \(phone)")
        }
        if !dateOfBirth.isEmpty {
            contact.append("\nGeburtstag: \(dateOfBirth)")
        }
        return contact
    }

    private enum CodingKeys: String, CodingKey {
        case address, firstName, name, phone
    }
}

extension ContactState {
    static var empty: ContactState {
        ContactState(
            firstName: "",
            name: "",
            address: .init(),
            phone: ""
        )
    }

    static var preview: ContactState {
        ContactState(
            firstName: RowType.firstName.placeholder,
            name: RowType.lastName.placeholder,
            address: .init(
                street: RowType.street.placeholder,
                postalCode: RowType.zipCode.placeholder,
                city: RowType.town.placeholder
            ),
            phone: RowType.phone.placeholder
        )
    }
}

extension ContactState.Address {
    init(address: CNPostalAddress) {
        street = address.street
        postalCode = address.postalCode
        city = address.city
    }

    var humanReadableAddress: String {
        "\(street), \(postalCode) \(city)"
    }
}

// MARK: - Action

enum ContactAction: Equatable {
    case firstNameChanged(String)
    case lastNameChanged(String)
    case phoneChanged(String)
    case streetChanged(String)
    case zipCodeChanged(String)
    case townChanged(String)
    case dateOfBirthChanged(String)
    case addressAdditionChanged(String)
    case resetContactDataButtonTapped
    case resetContactConfirmButtonTapped
    case dismissAlert
    case onDisappear
}

// MARK: - Environment

struct ContactEnvironment {}

/// Reducer handling ContactView actions
let contactReducer = Reducer<ContactState, ContactAction, ContactEnvironment> { state, action, _ in
    switch action {
    case let .firstNameChanged(firstName):
        state.firstName = firstName
        return .none
    case let .lastNameChanged(lastName):
        state.name = lastName
        return .none
    case let .phoneChanged(phone):
        state.phone = phone
        return .none
    case let .streetChanged(street):
        state.address.street = street
        return .none
    case let .townChanged(town):
        state.address.city = town
        return .none
    case let .zipCodeChanged(zipCode):
        state.address.postalCode = zipCode
        return .none
    case let .dateOfBirthChanged(date):
        state.dateOfBirth = date
        return .none
    case let .addressAdditionChanged(addition):
        state.address.addition = addition
        return .none
    case .resetContactDataButtonTapped:
        state.alert = .resetContactDataAlert
        return .none
    case .resetContactConfirmButtonTapped:
        state = .empty
        return Effect(value: .dismissAlert)
    case .dismissAlert:
        state.alert = nil
        return .none
    case .onDisappear:
        return .none
    }
}

extension AlertState where Action == ContactAction {
    static let resetContactDataAlert = Self(
        title: TextState(L10n.Contact.Alert.title),
        primaryButton: .destructive(
            TextState(L10n.Contact.Alert.reset),
            action: .send(.resetContactConfirmButtonTapped)
        ),
        secondaryButton: .cancel(.init(L10n.cancel), action: .send(.dismissAlert))
    )
}
