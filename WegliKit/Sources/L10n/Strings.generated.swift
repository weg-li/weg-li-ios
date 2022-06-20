// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

import Foundation

// swiftlint:disable superfluous_disable_command file_length implicit_return

// MARK: - Strings

// swiftlint:disable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:disable nesting type_body_length type_name vertical_whitespace_opening_braces
public enum L10n {
  /// Abbrechen
  public static let cancel = L10n.tr("Localizable", "cancel")
  /// Datum
  public static let date = L10n.tr("Localizable", "date")
  /// Meldungen
  public static let notices = L10n.tr("Localizable", "notices")

  public enum Button {
    /// Schließen
    public static let close = L10n.tr("Localizable", "button.close")
    /// Zurücksetzen
    public static let reset = L10n.tr("Localizable", "button.reset")
    public enum Submit {
      /// Bezirk: %@
      public static func district(_ p1: Any) -> String {
        return L10n.tr("Localizable", "button.submit.district", String(describing: p1))
      }
      /// Meldung erstatten
      public static let title = L10n.tr("Localizable", "button.submit.title")
    }
  }

  public enum Contact {
    /// Kontaktdaten bearbeiten
    public static let editButtonCopy = L10n.tr("Localizable", "contact.editButtonCopy")
    /// Deine Adresse wird lokal in der App gespeichert, um diese im Report schon vorauszufüllen.
    public static let isSavedInAppHintCopy = L10n.tr("Localizable", "contact.isSavedInAppHintCopy")
    /// Ihre Emailadresse wird über die Mail App konfiguriert.
    public static let mailInfo = L10n.tr("Localizable", "contact.mailInfo")
    /// Die Meldung kann nur bearbeitet werden, wenn du richtige Angaben zu deiner Person machst.
    public static let reportHintCopy = L10n.tr("Localizable", "contact.reportHintCopy")
    /// Kontaktdaten
    public static let widgetTitle = L10n.tr("Localizable", "contact.widgetTitle")
    public enum Alert {
      /// Zurücksetzen
      public static let reset = L10n.tr("Localizable", "contact.alert.reset")
      /// Daten zurücksetzen?
      public static let title = L10n.tr("Localizable", "contact.alert.title")
    }
    public enum Row {
      /// Addresszusatz
      public static let addressAddition = L10n.tr("Localizable", "contact.row.addressAddition")
      /// Stadt
      public static let cityCopy = L10n.tr("Localizable", "contact.row.cityCopy")
      /// Geburtstag
      public static let dateOfBirth = L10n.tr("Localizable", "contact.row.dateOfBirth")
      /// Name
      public static let nameCopy = L10n.tr("Localizable", "contact.row.nameCopy")
      /// Telefon
      public static let phoneCopy = L10n.tr("Localizable", "contact.row.phoneCopy")
      /// Strasse
      public static let streetCopy = L10n.tr("Localizable", "contact.row.streetCopy")
    }
    public enum RowType {
      /// Stadt
      public static let city = L10n.tr("Localizable", "contact.rowType.city")
      /// Vorname
      public static let firstName = L10n.tr("Localizable", "contact.rowType.firstName")
      /// Nachname
      public static let lastName = L10n.tr("Localizable", "contact.rowType.lastName")
      /// Telefon
      public static let phone = L10n.tr("Localizable", "contact.rowType.phone")
      /// Strasse
      public static let street = L10n.tr("Localizable", "contact.rowType.street")
      /// PLZ
      public static let zipCode = L10n.tr("Localizable", "contact.rowType.zipCode")
    }
    public enum Section {
      /// Optional
      public static let `optional` = L10n.tr("Localizable", "contact.section.optional")
      /// Erforderlich
      public static let `required` = L10n.tr("Localizable", "contact.section.required")
    }
  }

  public enum Description {
    /// Beschreibung
    public static let widgetTitle = L10n.tr("Localizable", "description.widgetTitle")
    public enum EditButton {
      /// Beschreibung bearbeiten
      public static let copy = L10n.tr("Localizable", "description.editButton.copy")
    }
    public enum Row {
      /// Farbe
      public static let carColor = L10n.tr("Localizable", "description.row.carColor")
      /// Marke
      public static let carType = L10n.tr("Localizable", "description.row.carType")
      /// Art des Verstoßes
      public static let chargeType = L10n.tr("Localizable", "description.row.chargeType")
      /// Behinderung anderer Verkehrsteilnehmer
      public static let didBlockOthers = L10n.tr("Localizable", "description.row.didBlockOthers")
      /// Dauer
      public static let length = L10n.tr("Localizable", "description.row.length")
      /// Kennzeichen
      public static let licenseplateNumber = L10n.tr("Localizable", "description.row.licenseplateNumber")
    }
    public enum Section {
      public enum Vehicle {
        /// Fahrzeug
        public static let copy = L10n.tr("Localizable", "description.section.vehicle.copy")
      }
      public enum Violation {
        /// Verstoß
        public static let copy = L10n.tr("Localizable", "description.section.violation.copy")
      }
    }
  }

  public enum Home {
    /// Keine gespeicherten Meldungen
    public static let emptyStateCopy = L10n.tr("Localizable", "home.emptyStateCopy")
    /// Meldungen
    public static let navigationBarTitle = L10n.tr("Localizable", "home.navigationBarTitle")
    public enum A11y {
      /// Meldung erstellen
      public static let addReportButtonLabel = L10n.tr("Localizable", "home.a11y.addReportButtonLabel")
    }
  }

  public enum Location {
    /// Ort
    public static let widgetTitle = L10n.tr("Localizable", "location.widgetTitle")
    public enum A11y {
      /// Karteansicht erweitern
      public static let expandButtonLabel = L10n.tr("Localizable", "location.a11y.expandButtonLabel")
    }
    public enum Alert {
      /// Es konnte keine Koordinate aus dem Foto gelesen werden.
      public static let noCoordinate = L10n.tr("Localizable", "location.alert.noCoordinate")
      /// Bitte geben Sie uns in den Einstellungen Zugriff auf Ihren Standort.
      public static let provideAccessToLocationService = L10n.tr("Localizable", "location.alert.provideAccessToLocationService")
      /// Die Standortnutzung macht diese App besser. Bitte geben Sie uns Zugang.
      public static let provideAuth = L10n.tr("Localizable", "location.alert.provideAuth")
      /// Ortungsdienste sind deaktiviert.
      public static let serviceIsOff = L10n.tr("Localizable", "location.alert.serviceIsOff")
    }
    public enum PickerCopy {
      /// Standort
      public static let currentLocation = L10n.tr("Localizable", "location.pickerCopy.currentLocation")
      /// Aus Fotos
      public static let fromPhotos = L10n.tr("Localizable", "location.pickerCopy.fromPhotos")
      /// Manuell
      public static let manual = L10n.tr("Localizable", "location.pickerCopy.manual")
    }
    public enum Placeholder {
      /// Stadt
      public static let city = L10n.tr("Localizable", "location.placeholder.city")
      /// PLZ
      public static let postalCode = L10n.tr("Localizable", "location.placeholder.postalCode")
      /// Straße + Hausnummer
      public static let street = L10n.tr("Localizable", "location.placeholder.street")
    }
  }

  public enum Mail {
    /// Auf diesem Gerät können leider keine E-Mails versendet werden!
    public static let deviceErrorCopy = L10n.tr("Localizable", "mail.deviceErrorCopy")
    /// Gib alle nötigen Daten an um die Meldung zu versenden
    public static let readyToSubmitErrorCopy = L10n.tr("Localizable", "mail.readyToSubmitErrorCopy")
  }

  public enum Notice {
    /// Neue Meldung
    public static let add = L10n.tr("Localizable", "notice.add")
  }

  public enum Photos {
    /// Fotos
    public static let widgetTitle = L10n.tr("Localizable", "photos.widgetTitle")
    public enum Alert {
      /// Um Fotos hinzuzufügen braucht die App deine Zustimmung
      public static let accessDenied = L10n.tr("Localizable", "photos.alert.accessDenied")
    }
    public enum ImportButton {
      /// Fotos auswählen
      public static let copy = L10n.tr("Localizable", "photos.importButton.copy")
    }
  }

  public enum Report {
    /// Neue Meldung
    public static let navigationBarTitle = L10n.tr("Localizable", "report.navigationBarTitle")
    public enum Alert {
      /// Zurücksetzen
      public static let reset = L10n.tr("Localizable", "report.alert.reset")
      /// Meldung zurücksetzen?
      public static let title = L10n.tr("Localizable", "report.alert.title")
    }
    public enum Contact {
      /// Kontaktdaten
      public static let widgetTitle = L10n.tr("Localizable", "report.contact.widgetTitle")
    }
    public enum Error {
      /// Die Meldung enthält keine Kontaktdaten
      public static let contact = L10n.tr("Localizable", "report.error.contact")
      /// Die Meldung enthält keine Beschreibung
      public static let description = L10n.tr("Localizable", "report.error.description")
      /// Die Meldung enthält keine Bilder
      public static let images = L10n.tr("Localizable", "report.error.images")
      /// Die Meldung enthält keine Adresse der Tat
      public static let location = L10n.tr("Localizable", "report.error.location")
    }
    public enum Notice {
      /// Meldung hinzufügen
      public static let add = L10n.tr("Localizable", "report.notice.add")
      public enum Photos {
        /// Beim auswählen eines Fotos wird das Datum aus den Metadaten des Fotos ausgelesen
        public static let dateHint = L10n.tr("Localizable", "report.notice.photos.dateHint")
      }
    }
    public enum Place {
      /// Ort
      public static let widgetTitle = L10n.tr("Localizable", "report.place.widgetTitle")
    }
  }

  public enum Settings {
    /// Einstellungen
    public static let title = L10n.tr("Localizable", "settings.title")
    public enum Row {
      /// Beitragen
      public static let contribute = L10n.tr("Localizable", "settings.row.contribute")
      /// Spenden
      public static let donate = L10n.tr("Localizable", "settings.row.donate")
      /// Impressum
      public static let imprint = L10n.tr("Localizable", "settings.row.imprint")
      /// Lizenzen
      public static let licenses = L10n.tr("Localizable", "settings.row.licenses")
    }
    public enum Section {
      /// Projekt
      public static let projectTitle = L10n.tr("Localizable", "settings.section.projectTitle")
    }
  }

  public enum Times {
    public enum Description {
      /// länger als %@ Minuten
      public static func longerThenNMinutes(_ p1: Any) -> String {
        return L10n.tr("Localizable", "times.description.longerThenNMinutes", String(describing: p1))
      }
      /// länger als %@ Stunde
      public static func longerThenNStunde(_ p1: Any) -> String {
        return L10n.tr("Localizable", "times.description.longerThenNStunde", String(describing: p1))
      }
      /// länger als %@ Stunden
      public static func longerThenNStunden(_ p1: Any) -> String {
        return L10n.tr("Localizable", "times.description.longerThenNStunden", String(describing: p1))
      }
      /// bis zu 3 Minuten
      public static let upTo3 = L10n.tr("Localizable", "times.description.upTo3")
    }
  }

  public enum Widget {
    public enum A11y {
      /// erweitern
      public static let toggleCollapseButtonLabel = L10n.tr("Localizable", "widget.a11y.toggleCollapseButtonLabel")
      public enum CompletionIndicatorLabel {
        /// ist nicht gültig
        public static let isNotValid = L10n.tr("Localizable", "widget.a11y.completionIndicatorLabel.isNotValid")
        /// ist gültig
        public static let isValid = L10n.tr("Localizable", "widget.a11y.completionIndicatorLabel.isValid")
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
