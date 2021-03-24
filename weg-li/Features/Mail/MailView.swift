//
//  MailComposer.swift
//  weg-li
//
//  Created by Malte Bünz on 15.06.20.
//  Copyright © 2020 Stefan Trauth. All rights reserved.
//

import MessageUI
import SwiftUI

struct MailView: UIViewControllerRepresentable {
    @Binding var isShowing: Bool
    @Binding var result: Result<MFMailComposeResult, Error>?
    
    let report: Report
    let contact: ContactState?
    
    class Coordinator: NSObject, MFMailComposeViewControllerDelegate {
        @Binding var isShowing: Bool
        @Binding var result: Result<MFMailComposeResult, Error>?
        
        init(isShowing: Binding<Bool>,
             result: Binding<Result<MFMailComposeResult, Error>?>, report: Report, contact: ContactState?) {
            _isShowing = isShowing
            _result = result
        }
        
        func mailComposeController(
            _ controller: MFMailComposeViewController,
            didFinishWith result: MFMailComposeResult,
            error: Error?) {
            defer {
                isShowing = false
            }
            guard error == nil else {
                self.result = .failure(error!)
                return
            }
            self.result = .success(result)
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(
            isShowing: $isShowing,
            result: $result,
            report: report,
            contact: contact)
    }
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<MailView>) -> MFMailComposeViewController {
        let vc = MFMailComposeViewController()
        vc.setToRecipients([report.district?.mail ?? ""])
        vc.setSubject("Anzeige mit der Bitte um Weiterverfolgung")
        vc.setMessageBody(
            """
            Sehr geehrte Damen und Herren,

            
            hiermit zeige ich, mit der Bitte um Weiterverfolgung, folgende Verkehrsordnungswidrigkeit an:

            Kennzeichen: \(report.car.licensePlateNumber ?? "")

            Marke: \(report.car.type ?? "")

            Farbe: \(report.car.color ?? "")

            Adresse: \(report.contact.address.humanReadableAddress)

            Verstoß: \(Report.Charge.charges[report.charge.selectedType])

            Tatzeit: \(report.date.humandReadableDate)

            Zeitraum: 12:25 ~ 15:25 \(report.charge.time)

            Das Fahrzeug war verlassen.


            Zeuge:

            Name: \(contact.map { $0.firstName + $0.name } ?? "")

            Anschrift: \(contact.map { $0.address.humanReadableAddress } ?? "")

            Meine oben gemachten Angaben einschließlich meiner Personalien sind zutreffend und vollständig.
            Als Zeuge bin ich zur wahrheitsgemäßen Aussage und auch zu einem möglichen Erscheinen vor Gericht verpflichtet.
            Vorsätzlich falsche Angaben zu angeblichen Ordnungswidrigkeiten können eine Straftat darstellen.


            Beweisfotos, aus denen Kennzeichen und Tatvorwurf erkennbar hervorgehen, befinden sich im Anhang.
            Bitte prüfen Sie den Sachverhalt auch auf etwaige andere Verstöße, die aus den Beweisfotos zu ersehen sind.


            Bitte bestätigen Sie Ihre Zuständigkeit und den Erhalt dieser E-Mail durch eine Antwort.
            Falls Sie nicht zuständig sein sollten, leiten Sie bitte meine E-Mail weiter und setzen mich dabei in CC.
            Dabei dürfen Sie auch meine persönlichen Daten weiterleiten und für die Dauer des Verfahrens speichern.


            Mit freundlichen Grüßen

            \(contact.map { $0.firstName + $0.name } ?? "")
            """, isHTML: false)
        report.storedPhotos.enumerated().forEach { index, image in
            vc.addAttachmentData(
                image.image,
                mimeType: "image/jpeg",
                fileName: "\(report.car)_\(index)")
        }
        vc.mailComposeDelegate = context.coordinator
        return vc
    }
    
    func updateUIViewController(
        _ uiViewController: MFMailComposeViewController,
        context: UIViewControllerRepresentableContext<MailView>
    ) {}
}
