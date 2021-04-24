// Created for weg-li in 2021.

import Foundation

struct Mail: Equatable, Codable {
    var address: String = ""
    var subject: String = "Anzeige mit der Bitte um Weiterverfolgung"
    var body: String = ""
    var attachmentData: [Data] = []
}

extension Mail {
    static func createMailBody(from report: Report) -> String {
        return """
        Sehr geehrte Damen und Herren,


        hiermit zeige ich, mit der Bitte um Weiterverfolgung, folgende Verkehrsordnungswidrigkeit an:

        Kennzeichen: \(report.description.licensePlateNumber)

        Marke: \(report.description.selectedType)

        Farbe: \(DescriptionState.colors[report.description.selectedColor].value)

        Adresse: \(report.contact.address.humanReadableAddress)

        Verstoß: \(DescriptionState.charges[report.description.selectedType].value)

        Tatzeit: \(report.date.humandReadableTime)

        Zeitraum: \(report.description.time)

        Das Fahrzeug war verlassen.


        Zeuge:

        Name: \(report.contact.firstName) \(report.contact.name)

        Anschrift: \(report.contact.address.humanReadableAddress)

        Meine oben gemachten Angaben einschließlich meiner Personalien sind zutreffend und vollständig.
        Als Zeuge bin ich zur wahrheitsgemäßen Aussage und auch zu einem möglichen Erscheinen vor Gericht verpflichtet.
        Vorsätzlich falsche Angaben zu angeblichen Ordnungswidrigkeiten können eine Straftat darstellen.


        Beweisfotos, aus denen Kennzeichen und Tatvorwurf erkennbar hervorgehen, befinden sich im Anhang.
        Bitte prüfen Sie den Sachverhalt auch auf etwaige andere Verstöße, die aus den Beweisfotos zu ersehen sind.


        Bitte bestätigen Sie Ihre Zuständigkeit und den Erhalt dieser E-Mail durch eine Antwort.
        Falls Sie nicht zuständig sein sollten, leiten Sie bitte meine E-Mail weiter und setzen mich dabei in CC.
        Dabei dürfen Sie auch meine persönlichen Daten weiterleiten und für die Dauer des Verfahrens speichern.


        Mit freundlichen Grüßen

        \(report.contact.firstName) \(report.contact.name)
        """
    }
}
