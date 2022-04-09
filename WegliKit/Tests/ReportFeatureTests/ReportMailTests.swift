import ReportFeature
import XCTest

class ReportMailTests: XCTestCase {
  func test_MailGeneration() {
    let date = Date(timeIntervalSinceReferenceDate: 0)
    
    let report = Report(
      uuid: .init(),
      images: .init(
        alert: nil,
        showImagePicker: false,
        storedPhotos: [.init(uiImage: .init(systemName: "heart")!)],
        coordinateFromImagePicker: nil
      ),
      contactState: .preview,
      district: .init(
        name: "Hamburg",
        zip: "20099",
        email: "stapuli@hamburg.de",
        latitude: 33.22,
        longitude: 23.11,
        personalEmail: false
      ),
      date: { date },
      description: .init(
        licensePlateNumber: "B-HH-123",
        selectedColor: 1,
        selectedBrand: 1,
        selectedDuration: 4,
        selectedCharge: .init(
          id: "112402",
          text: "Parken verbotswidrig auf einem Gehweg",
          isFavorite: false,
          isSelected: true
        ),
        blockedOthers: true
      ),
      location: .init(
        resolvedAddress: .init(
          street: "Teststraße 23",
          postalCode: "12345",
          city: "Berlin"
        ),
        isRequestingCurrentLocation: true
      ),
      mail: .init(
        mailComposeResult: nil,
        mail: .init(
          address: "stapuli@hamburg.de",
          subject: "Anzeige mit der Bitte um Weiterverfolgung",
          body: "",
          attachmentData: [UIImage(systemName: "heart")!.pngData()].compactMap({ $0 })
        ),
        isPresentingMailContent: false
      )
    )
    
    let mailBody = report.createMailBody()
    
    let expectedBody = """
    Hallo,
    
    hiermit zeige ich, mit der Bitte um Weiterverfolgung, folgende Verkehrsordnungswidrigkeit an:
    
    Kennzeichen: B-HH-123
    
    Marke: Abarth
    
    Farbe: Beige
    
    Adresse:
    Teststraße 23
    12345 Berlin
    
    Verstoß: Parken verbotswidrig auf einem Gehweg
    
    Tatzeit: 01.01.2001, 01:00:00 MEZ
    
    Zeitraum: länger als 10 Minuten (01:00:00 – 01:10:00)
    
    Das Fahrzeug war verlassen.
    
    
    Zeuge:
    
    Name:
    Max Mustermann
    Telefonnummer: +491235346435
    
    Anschrift:
    Max-Brauer-Allee 23
    20095 Hamburg
    
    Meine oben gemachten Angaben einschließlich meiner Personalien sind zutreffend und vollständig.
    Als Zeuge bin ich zur wahrheitsgemäßen Aussage und auch zu einem möglichen Erscheinen vor Gericht verpflichtet.
    Vorsätzlich falsche Angaben zu angeblichen Ordnungswidrigkeiten können eine Straftat darstellen.
    
    
    Beweisfotos, aus denen Kennzeichen und Tatvorwurf erkennbar hervorgehen, befinden sich im Anhang.
    Bitte prüfen Sie den Sachverhalt auch auf etwaige andere Verstöße, die aus den Beweisfotos zu ersehen sind.
    
    
    Bitte bestätigen Sie Ihre Zuständigkeit und den Erhalt dieser E-Mail durch eine Antwort.
    Falls Sie nicht zuständig sein sollten, leiten Sie bitte meine E-Mail weiter und setzen mich dabei in CC.
    Dabei dürfen Sie auch meine persönlichen Daten weiterleiten und für die Dauer des Verfahrens speichern.
    
    
    Mit freundlichen Grüßen
    
    Max Mustermann
    """
    
    XCTAssertEqual(expectedBody, mailBody)
  }
}
