import DescriptionFeature
import Foundation
import Helper
import SharedModels

public extension ReportDomain.State {
  // swiftlint:disable:next function_body_length
  func createMailBody() -> String {
    """
    Hallo,
    
    hiermit zeige ich, mit der Bitte um Weiterverfolgung, folgende Verkehrsordnungswidrigkeit an:
    
    Falldaten:
    
    Kennzeichen: \(description.licensePlateNumber)
    
    Marke: \(description.selectedBrand?.title ?? "")
    
    Farbe: \(DescriptionDomain.State.colors[description.selectedColor].value)
    
    Adresse:
    \(location.resolvedAddress.humanReadableAddress())
    
    Verstoß: \(description.selectedCharge?.text ?? "")\(description.blockedOthers ? ", mit Behinderung (z.B. Anhalten, Ausweichen, Absteigen)" : "")
    
    Tatzeit: \(date.humandReadableTimeAndDate)
    
    Zeitraum: \(description.timeInterval(from: date))
    
    Das Fahrzeug war verlassen.
    
    
    Zeuge:
    
    \(contactState.contact.humanReadableContact)
    \(contactState.contact.address.humanReadableAddress())
    
    Meine oben gemachten Angaben einschließlich meiner Personalien sind zutreffend und vollständig.
    Als Zeuge bin ich zur wahrheitsgemäßen Aussage und auch zu einem möglichen Erscheinen vor Gericht verpflichtet.
    Vorsätzlich falsche Angaben zu angeblichen Ordnungswidrigkeiten können eine Straftat darstellen.
    
    
    Beweisfotos, aus denen Kennzeichen und Tatvorwurf erkennbar hervorgehen, befinden sich im Anhang.
    Bitte prüfen Sie den Sachverhalt auch auf etwaige andere Verstöße, die aus den Beweisfotos zu ersehen sind.
    
    
    Bitte bestätigen Sie Ihre Zuständigkeit und den Erhalt dieser E-Mail durch eine Antwort.
    Falls Sie nicht zuständig sein sollten, leiten Sie bitte meine E-Mail weiter und setzen mich dabei in CC.
    Dabei dürfen Sie auch meine persönlichen Daten weiterleiten und für die Dauer des Verfahrens speichern.
    
    
    Mit freundlichen Grüßen
    
    \(contactState.contact.fullName)
    """
  }
}
