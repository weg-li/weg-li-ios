// Created for weg-li in 2021.

import Combine
import CoreLocation
import Foundation

func appReducer(
    state: inout AppState,
    action: AppAction,
    environment: EnvironmentContainer) -> AnyPublisher<AppAction, Never>
{
    switch action {
    // MARK: Handle location actions

    case let .handleLocationAction(locationAction):
        switch locationAction {
        case .onLocationAppear:
            return Just(AppAction.handleLocationAction(.requestPermission))
                .eraseToAnyPublisher()
        case .requestPermission:
            return Future<Int, Never> { promise in
                environment.locationProvider.requestPermission()
                return promise(.success(1))
            }
            .delay(for: 3.0, scheduler: RunLoop.main)
            .receive(on: RunLoop.main)
            .map { _ in AppAction.handleLocationAction(.requestLocation) }
            .eraseToAnyPublisher()
        case .requestLocation:
            environment.locationProvider.requestLocation()
            return environment.locationProvider
                .location
                .removeDuplicates()
                .replaceError(with: CLLocation(latitude: 0, longitude: 0))
                .map { AppAction.handleLocationAction(.setLocation($0.coordinate)) }
                .eraseToAnyPublisher()
        case let .resolveAddress(option):
            switch option {
            case .currentLocation:
                break
            case .fromPhotos:
                environment.exifReader.readLocationMetaData(from: state.report.images)
            case .manual:
                print("👨‍🏭")
            }
        case let .setUserDefinedLocation(coordinate):
            state.location.userDefinedLocation = coordinate
        case let .setLocation(location):
            state.location.location = location
            return environment.geoCoder
                .getPlacemarks(for: CLLocation(latitude: location.latitude, longitude: location.longitude))
                .replaceError(with: [])
                .map { AppAction.handleLocationAction(.setResolvedAddress($0.first)) }
                .eraseToAnyPublisher()
        case let .setResolvedAddress(address):
            guard state.location.presumedAddress != address else { break }
            state.location.presumedAddress = address
            if let address = address {
                return Just(AppAction.handleDescriptionAction(.resolveDistrict(address)))
                    .eraseToAnyPublisher()
            }
        }
    case let .setContact(contact):
        state.contact = contact
        environment.personalDataRepository.contact = contact
    case let .addImage(image):
        environment.dataStore.add(image: image)
        state.report.images = environment.dataStore.images
    case let .removeImage(image):
        environment.dataStore.remove(image: image)
        state.report.images = environment.dataStore.images

    // MARK: Handle description actions

    case let .handleDescriptionAction(descriptionAction):
        switch descriptionAction {
        case let .setCar(car):
            state.report.car = car
        case let .setCharge(charge):
            state.report.charge = charge
            state.report.date = Date()
        case let .resolveDistrict(address):
            return District.mapAddressToDistrict(address)
                .compactMap { $0 }
                .map { AppAction.handleDescriptionAction(.setDistrict($0)) }
                .eraseToAnyPublisher()
        case let .setDistrict(district):
            state.report.district = district
        }
    }
    return Empty().eraseToAnyPublisher()
}

typealias Reducer<State, Action, Environment> =
    (inout State, Action, Environment) -> AnyPublisher<Action, Never>?
