// Created for weg-li in 2021.

import ComposableArchitecture
import ComposableCoreLocation
import MessageUI
import SwiftUI

// MARK: - Report Core

struct Report: Codable {
    var id: String
    var images: ImagesViewState
    var contact: ContactState
    var district: District?

    var date: Date
    var description: DescriptionState
    var location: LocationViewState
    var mail: MailViewState

    init(
        uuid: UUID = UUID(),
        images: ImagesViewState,
        contact: ContactState,
        district: District? = nil,
        date: () -> Date = Date.init,
        description: DescriptionState = DescriptionState(),
        location: LocationViewState = LocationViewState(),
        mail: MailViewState = MailViewState()
    ) {
        id = uuid.uuidString
        self.images = images
        self.contact = contact
        self.district = district
        self.date = date()
        self.description = description
        self.location = location
        self.mail = mail
    }
}

extension Report: Equatable {
    static func == (lhs: Report, rhs: Report) -> Bool {
        return lhs.contact == rhs.contact
            && lhs.district == rhs.district
            && lhs.description == rhs.description
            && lhs.location == rhs.location
    }
}

enum ReportAction: Equatable {
    case images(ImagesViewAction)
    case contact(ContactAction)
    case description(DescriptionAction)
    case location(LocationViewAction)
    case mail(MailViewAction)
    case mapGeoAddressToDistrict(GeoAddress)
    case mapDistrictFinished(Result<District, RegularityOfficeMapError>)
}

struct ReportEnvironment {
    var mainQueue: AnySchedulerOf<DispatchQueue>
    var locationManager: LocationManager
    var placeService: PlacesServiceClient
    var regulatoryOfficeMapper: RegulatoryOfficeMapper

    let debounce = 1
    let postalCodeMinumimCharacters = 5
}

/// Combined reducer that is used in the ReportView and combing descending reducers.
let reportReducer = Reducer<Report, ReportAction, ReportEnvironment>.combine(
    imagesReducer.pullback(
        state: \.images,
        action: /ReportAction.images,
        environment: { reportEnvironment in ImagesViewEnvironment(
            mainQueue: reportEnvironment.mainQueue,
            imageConverter: .live(),
            photoLibraryAccessClient: .live()
        )
        }
    ),
    descriptionReducer.pullback(
        state: \.description,
        action: /ReportAction.description,
        environment: { _ in DescriptionEnvironment() }
    ),
    contactReducer.pullback(
        state: \.contact,
        action: /ReportAction.contact,
        environment: { _ in ContactEnvironment() }
    ),
    locationReducer.pullback(
        state: \.location,
        action: /ReportAction.location,
        environment: {
            LocationViewEnvironment(
                locationManager: $0.locationManager,
                placeService: $0.placeService
            )
        }
    ),
    mailViewReducer.pullback(
        state: \.mail,
        action: /ReportAction.mail,
        environment: { _ in MailViewEnvironment() }
    ),
    Reducer { state, action, environment in
        struct LocationManagerId: Hashable {}
        struct DebounceID: Hashable {}

        switch action {
        // Triggers district mapping after geoAddress is stored.
        case let .mapGeoAddressToDistrict(input):
            return environment
                .regulatoryOfficeMapper
                .mapAddressToDistrict(input)
                .catchToEffect()
                .map(ReportAction.mapDistrictFinished)
                .eraseToEffect()
                .debounce(
                    id: DebounceID(),
                    for: .seconds(environment.debounce),
                    scheduler: environment.mainQueue
                )

        case let .mapDistrictFinished(.success(district)):
            state.district = district
            return .none
        case let .mapDistrictFinished(.failure(error)):
            // present alert maybe?
            debugPrint(error.message)
            return .none

        case let .images(imageViewAction):
            switch imageViewAction {
            // After the images coordinate was set trigger resolve location and map to district.
            case let .setResolvedCoordinate(coordinate):
                guard let coordinate = coordinate, coordinate != state.location.userLocationState.region?.center else {
                    return .none
                }
                state.location.userLocationState.region = CoordinateRegion(center: coordinate)
                state.images.coordinateFromImagePicker = coordinate
                return Effect(value: ReportAction.location(.resolveLocation(coordinate)))
            // Handle single image remove action to reset map annotations and reset valid state.
            case .image:
                if state.images.storedPhotos.isEmpty, state.location.locationOption == .fromPhotos {
                    state.images.coordinateFromImagePicker = nil
                    state.location.resolvedAddress = .empty
                }
                return .none
            default:
                return .none
            }
        case let .location(locationAction):
            switch locationAction {
            // Trigger district mapping after address is resolved.
            case let .resolveAddressFinished(addressResult):
                guard let address = try? addressResult.get().first else {
                    return .none
                }
                return Effect(value: ReportAction.mapGeoAddressToDistrict(address))

            // Handle manual address entering to trigger district mapping.
            case let .updateGeoAddressPostalCode(postalCode):
                guard postalCode.count == environment.postalCodeMinumimCharacters, postalCode.isNumeric else {
                    return .none
                }
                return Effect(value: ReportAction.mapGeoAddressToDistrict(state.location.resolvedAddress))
            case let .updateGeoAddressCity(city):
                return Effect(value: ReportAction.mapGeoAddressToDistrict(state.location.resolvedAddress))
            default:
                return .none
            }
        // Compose mail when send mail button was tapped.
        case let .mail(mailAction):
            if MailViewAction.submitButtonTapped == mailAction {
                guard let district = state.district else {
                    return .none
                }
                state.mail.mail.address = district.mail
                state.mail.mail.body = Mail.createMailBody(from: state)
                state.mail.mail.attachmentData = state.images.storedPhotos
                    .compactMap { $0 }
                    .map(\.image)
                return Effect(value: ReportAction.mail(.presentMailContentView(true)))
            } else {
                return .none
            }
        case .contact, .description:
            return .none
        }
    }
)

extension Report {
    static var preview: Report {
        Report(
            uuid: UUID(),
            images: .init(
                showImagePicker: false,
                storedPhotos: [StorableImage(uiImage: UIImage(systemName: "trash")!)!]
            ),
            contact: .preview,
            district: District(
                name: "Hamburg St. Pauli",
                zipCode: "20099",
                mail: "mail@stpauli.de"
            ),
            date: Date.init,
            description: .init(
                color: "Gelb",
                type: "Kleinbus",
                licensePlateNumber: "HH-ST-PAULI",
                selectedDuration: 0,
                selectedType: 0,
                blockedOthers: false
            ),
            location: LocationViewState()
        )
    }
}
