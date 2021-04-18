// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

import Foundation

// swiftlint:disable superfluous_disable_command file_length implicit_return

// MARK: - Strings

// swiftlint:disable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:disable nesting type_body_length type_name vertical_whitespace_opening_braces
internal enum L10n {

  internal enum Contact {
    /// Kontaktdaten bearbeiten
    internal static let editButtonCopy = L10n.tr("Localizable", "contact.editButtonCopy")
    /// Deine Adresse wird lokal in der App gespeichert, um diese im Report schon vorauszufüllen.
    internal static let isSavedInAppHintCopy = L10n.tr("Localizable", "contact.isSavedInAppHintCopy")
    /// Die Anzeige kann nur bearbeitet werden, wenn du richtige Angaben zu deiner Person machst.
    internal static let reportHintCopy = L10n.tr("Localizable", "contact.reportHintCopy")
    /// Kontaktdaten
    internal static let widgetTitle = L10n.tr("Localizable", "contact.widgetTitle")
    internal enum Alert {
      /// Zurücksetzen
      internal static let reset = L10n.tr("Localizable", "contact.alert.reset")
      /// Daten zurücksetzen?
      internal static let title = L10n.tr("Localizable", "contact.alert.title")
    }
    internal enum Row {
      /// Stadt
      internal static let cityCopy = L10n.tr("Localizable", "contact.row.cityCopy")
      /// Name
      internal static let nameCopy = L10n.tr("Localizable", "contact.row.nameCopy")
      /// Telefon
      internal static let phoneCopy = L10n.tr("Localizable", "contact.row.phoneCopy")
      /// Strasse
      internal static let streetCopy = L10n.tr("Localizable", "contact.row.streetCopy")
    }
    internal enum RowType {
      /// Stadt
      internal static let city = L10n.tr("Localizable", "contact.rowType.city")
      /// Vorname
      internal static let firstName = L10n.tr("Localizable", "contact.rowType.firstName")
      /// Nachname
      internal static let lastName = L10n.tr("Localizable", "contact.rowType.lastName")
      /// Telefon
      internal static let phone = L10n.tr("Localizable", "contact.rowType.phone")
      /// Strasse
      internal static let street = L10n.tr("Localizable", "contact.rowType.street")
      /// PLZ
      internal static let zipCode = L10n.tr("Localizable", "contact.rowType.zipCode")
    }
  }

  internal enum Description {
    /// Beschreibung
    internal static let widgetTitle = L10n.tr("Localizable", "description.widgetTitle")
    internal enum EditButton {
      /// Beschreibung bearbeiten
      internal static let copy = L10n.tr("Localizable", "description.editButton.copy")
    }
    internal enum Row {
      /// Farbe
      internal static let carColor = L10n.tr("Localizable", "description.row.carColor")
      /// Marke
      internal static let carType = L10n.tr("Localizable", "description.row.carType")
      /// Art des Verstoßes
      internal static let chargeType = L10n.tr("Localizable", "description.row.chargeType")
      /// Behinderung anderer Verkehrsteilnehmer
      internal static let didBlockOthers = L10n.tr("Localizable", "description.row.didBlockOthers")
      /// Dauer
      internal static let length = L10n.tr("Localizable", "description.row.length")
      /// Kennzeichen
      internal static let licensplateNumber = L10n.tr("Localizable", "description.row.licensplateNumber")
    }
    internal enum Section {
      internal enum Vehicle {
        /// Fahrzeug
        internal static let copy = L10n.tr("Localizable", "description.section.vehicle.copy")
      }
      internal enum Violation {
        /// Verstoß
        internal static let copy = L10n.tr("Localizable", "description.section.violation.copy")
      }
    }
  }

  internal enum Home {
    /// Keine gespeicherten Anzeigen
    internal static let emptyStateCopy = L10n.tr("Localizable", "home.emptyStateCopy")
    /// Anzeigen
    internal static let navigationBarTitle = L10n.tr("Localizable", "home.navigationBarTitle")
    internal enum A11y {
      /// Anzeige erstellen
      internal static let addReportButtonLabel = L10n.tr("Localizable", "home.a11y.addReportButtonLabel")
    }
  }

  internal enum Location {
    /// Ort
    internal static let widgetTitle = L10n.tr("Localizable", "location.widgetTitle")
    internal enum A11y {
      /// Karteansicht erweitern
      internal static let expandButtonLabel = L10n.tr("Localizable", "location.a11y.expandButtonLabel")
    }
    internal enum Alert {
      /// Bitte geben Sie uns in den Einstellungen Zugriff auf Ihren Standort.
      internal static let provideAccessToLocationService = L10n.tr("Localizable", "location.alert.provideAccessToLocationService")
      /// Die Standortnutzung macht diese App besser. Bitte geben Sie uns Zugang.
      internal static let provideAuth = L10n.tr("Localizable", "location.alert.provideAuth")
      /// Ortungsdienste sind deaktiviert.
      internal static let serviceIsOff = L10n.tr("Localizable", "location.alert.serviceIsOff")
    }
    internal enum PickerCopy {
      /// Standort
      internal static let currentLocation = L10n.tr("Localizable", "location.pickerCopy.currentLocation")
      /// Aus Fotos
      internal static let fromPhotos = L10n.tr("Localizable", "location.pickerCopy.fromPhotos")
      /// Manuell
      internal static let manual = L10n.tr("Localizable", "location.pickerCopy.manual")
    }
    internal enum Placeholder {
      /// Stadt
      internal static let city = L10n.tr("Localizable", "location.placeholder.city")
      /// PLZ
      internal static let postalCode = L10n.tr("Localizable", "location.placeholder.postalCode")
      /// Straße + Hausnummer
      internal static let street = L10n.tr("Localizable", "location.placeholder.street")
    }
  }

  internal enum Mail {
    /// Auf diesem Gerät können leider keine E-Mails versendet werden!
    internal static let deviceErrorCopy = L10n.tr("Localizable", "mail.deviceErrorCopy")
    /// Gib alle nötigen Daten an um die Anzeige zu versenden
    internal static let readyToSubmitErrorCopy = L10n.tr("Localizable", "mail.readyToSubmitErrorCopy")
  }

  internal enum Photos {
    /// Fotos
    internal static let widgetTitle = L10n.tr("Localizable", "photos.widgetTitle")
    internal enum Alert {
      /// Um Fotos hinzuzufügen braucht die App deine Zustimmung
      internal static let accessDenied = L10n.tr("Localizable", "photos.alert.accessDenied")
    }
    internal enum ImportButton {
      /// Fotos importieren
      internal static let copy = L10n.tr("Localizable", "photos.importButton.copy")
    }
  }

  internal enum Report {
    /// Anzeige
    internal static let navigationBarTitle = L10n.tr("Localizable", "report.navigationBarTitle")
    internal enum Alert {
      /// Zurücksetzen
      internal static let reset = L10n.tr("Localizable", "report.alert.reset")
      /// Anzeige zurücksetzen?
      internal static let title = L10n.tr("Localizable", "report.alert.title")
    }
    internal enum Contact {
      /// Kontaktdaten
      internal static let widgetTitle = L10n.tr("Localizable", "report.contact.widgetTitle")
    }
    internal enum Place {
      /// Ort
      internal static let widgetTitle = L10n.tr("Localizable", "report.place.widgetTitle")
    }
  }

  internal enum Settings {
    /// Einstellungen
    internal static let title = L10n.tr("Localizable", "settings.title")
    internal enum Row {
      /// Beitragen
      internal static let contribute = L10n.tr("Localizable", "settings.row.contribute")
      /// Impressum
      internal static let imprint = L10n.tr("Localizable", "settings.row.imprint")
      /// Lizenzen
      internal static let licenses = L10n.tr("Localizable", "settings.row.licenses")
    }
    internal enum Section {
      /// Projekt
      internal static let projectTitle = L10n.tr("Localizable", "settings.section.projectTitle")
    }
  }

  internal enum Widget {
    internal enum A11y {
      /// erweitern
      internal static let toggleCollapseButtonLabel = L10n.tr("Localizable", "widget.a11y.toggleCollapseButtonLabel")
      internal enum CompletionIndicatorLabel {
        /// ist nicht gültig
        internal static let isNotValid = L10n.tr("Localizable", "widget.a11y.completionIndicatorLabel.isNotValid")
        /// ist gültig
        internal static let isValid = L10n.tr("Localizable", "widget.a11y.completionIndicatorLabel.isValid")
      }
    }
  }
}
// swiftlint:enable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:enable nesting type_body_length type_name vertical_whitespace_opening_braces

// MARK: - Implementation Details

extension L10n {
  private static func tr(_ table: String, _ key: String, _ args: CVarArg...) -> String {
    let format = BundleToken.bundle.localizedString(forKey: key, value: nil, table: table)
    return String(format: format, locale: Locale.current, arguments: args)
  }
}

// swiftlint:disable convenience_type
private final class BundleToken {
  static let bundle: Bundle = {
    #if SWIFT_PACKAGE
    return Bundle.module
    #else
    return Bundle(for: BundleToken.self)
    #endif
  }()
}
// swiftlint:enable convenience_type
