//
//  ReportForm.swift
//  weg-li
//
//  Created by Stefan Trauth on 08.10.19.
//  Copyright © 2019 Stefan Trauth. All rights reserved.
//

import ComposableArchitecture
import ComposableCoreLocation
import MessageUI
import SwiftUI

// MARK: - Report Core
struct Report: Codable {
    var uuid = UUID()
    var storedPhotos: [StorableImage] = []
    var images: ImagesViewState
    var contact: ContactState
    var district: District?
    
    var date: Date = Date()
    var car = Car()
    var charge = Charge()
    var location = LocationViewState(storedPhotos: [])
    var mail = MailViewState()
}

extension Report: Equatable {
    static func == (lhs: Report, rhs: Report) -> Bool {
        return lhs.contact == rhs.contact
            && lhs.district == rhs.district
            && lhs.car == rhs.car
            && lhs.charge == rhs.charge
            && lhs.location == rhs.location
    }
}

extension Report {
    struct Car: Equatable, Codable {
        var color: String = ""
        var type: String = ""
        var licensePlateNumber: String = ""
    }
    
    struct Charge: Equatable, Codable {
        var selectedDuration = 0
        var selectedType = 0
        var blockedOthers = false
        
        var time: String { Times.allCases[selectedDuration].description }
    }
    
    var isDescriptionValid: Bool {
        let isValid = ![car.type, car.color, car.licensePlateNumber]
            .map { $0.isEmpty }
            .contains(true)
        return isValid
    }
}

extension Report.Charge {
    static let charges = Bundle.main.decode([String].self, from: "charges.json")
    static let times = Times.allCases
}

enum ReportAction: Equatable {
    case images(ImagesViewAction)
    case contact(ContactAction)
    case car(CarAction)
    case charge(ChargeAction)
    case location(LocationViewAction)
    case mail(MailViewAction)
    case viewAppeared
    case createMail
}

struct ReportEnvironment {
    var locationManager: LocationManager
    var placeService: PlacesService
}

/// Combined reducer that is used in the ReportView
let reportReducer = Reducer<Report, ReportAction, ReportEnvironment>.combine(
    imagesReducer.pullback(
        state: \.images,
        action: /ReportAction.images,
        environment: { _ in ImagesViewEnvironment(imageConverter: ImageConverterImplementation()) }
    ),
    carReducer.pullback(
        state: \.car,
        action: /ReportAction.car,
        environment: { _ in CarEnvironment() }
    ),
    chargeReducer.pullback(
        state: \.charge,
        action: /ReportAction.charge,
        environment: { _ in ChargeEnvironment() }
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
        switch action {
        case let .images(imageViewAction):
            switch imageViewAction {
            case let .setResolvedCoordinate(coordinate):
                guard let coordinate = coordinate else {
                    return .none
                }
                state.location.userLocationState.region = CoordinateRegion(center: coordinate)
                return Effect(value: ReportAction.location(.resolveLocation(coordinate)))
            default:
                return .none
            }
        case .viewAppeared:
            return Effect(value: ReportAction.contact(.isContactValid))
        case .createMail:
            let district = District.mapAddressToDistrict(state.location.resolvedAddress) ?? District()
            state.mail.district = district
            state.mail.mail.address = district.mail
            state.mail.mail.body = state.createMailBody()
            return .none
        case .contact, .car, .charge, .location, .mail:
            return .none
        }
    }
)

// MARK: - Car Core
enum CarAction: Equatable {
    case type(String)
    case color(String)
    case licensePlateNumber(String)
}

struct CarEnvironment {}

/// Reducer resposonsible for updating the car object
let carReducer = Reducer<Report.Car, CarAction, CarEnvironment> { state, action, _ in
    switch action {
    case let .type(value):
        state.type = value
        return .none
    case let .color(value):
        state.color = value
        return .none
    case let .licensePlateNumber(value):
        state.licensePlateNumber = value
        return .none
    }
}

// MARK: - Charge Core
enum ChargeAction: Equatable {
    case toggleBlockedOthers
    case selectCharge(Int)
    case selectDuraration(Int)
}

struct ChargeEnvironment {}

/// Reducer resposonsible for updating the charge object
let chargeReducer = Reducer<Report.Charge, ChargeAction, ChargeEnvironment> { state, action, _ in
    switch action {
    case .toggleBlockedOthers:
        state.blockedOthers.toggle()
        return .none
    case let .selectCharge(value):
        state.selectedType = value
        return .none
    case let .selectDuraration(value):
        state.selectedDuration = value
        return .none
    }
}

extension Report {
    func createMailBody() -> String {
        return """
        Sehr geehrte Damen und Herren,


        hiermit zeige ich, mit der Bitte um Weiterverfolgung, folgende Verkehrsordnungswidrigkeit an:

        Kennzeichen: \(car.licensePlateNumber)

        Marke: \(car.type)

        Farbe: \(car.color)

        Adresse: \(contact.address.humanReadableAddress)

        Verstoß: \(Report.Charge.charges[charge.selectedType])

        Tatzeit: \(date.humandReadableDate)

        Zeitraum: \(charge.time)

        Das Fahrzeug war verlassen.


        Zeuge:

        Name: \(contact.firstName) \(contact.name)

        Anschrift: \(contact.address.humanReadableAddress)

        Meine oben gemachten Angaben einschließlich meiner Personalien sind zutreffend und vollständig.
        Als Zeuge bin ich zur wahrheitsgemäßen Aussage und auch zu einem möglichen Erscheinen vor Gericht verpflichtet.
        Vorsätzlich falsche Angaben zu angeblichen Ordnungswidrigkeiten können eine Straftat darstellen.


        Beweisfotos, aus denen Kennzeichen und Tatvorwurf erkennbar hervorgehen, befinden sich im Anhang.
        Bitte prüfen Sie den Sachverhalt auch auf etwaige andere Verstöße, die aus den Beweisfotos zu ersehen sind.


        Bitte bestätigen Sie Ihre Zuständigkeit und den Erhalt dieser E-Mail durch eine Antwort.
        Falls Sie nicht zuständig sein sollten, leiten Sie bitte meine E-Mail weiter und setzen mich dabei in CC.
        Dabei dürfen Sie auch meine persönlichen Daten weiterleiten und für die Dauer des Verfahrens speichern.


        Mit freundlichen Grüßen

        \(contact.firstName) \(contact.name)
        """
    }
    
    static var preview: Report {
        Report(
            uuid: UUID(),
            images: .init(
                showImagePicker: false,
                storedPhotos: []
            ),
            contact: .preview,
            district: District(
                name: "Hamburg St. Pauli",
                zipCode: "20099",
                mail: "mail@stpauli.de"
            ),
            date: Date(),
            car: Car(
                color: "Gelb",
                type: "Kleinbus",
                licensePlateNumber: "HH-ST-PAULI"
            ),
            charge: Charge(
                selectedDuration: 0,
                selectedType: 0,
                blockedOthers: false
            ),
            location: LocationViewState(storedPhotos: [])
        )
    }
}
