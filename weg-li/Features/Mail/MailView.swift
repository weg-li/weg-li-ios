// Created for weg-li in 2021.

import ComposableArchitecture
import MessageUI
import SwiftUI

struct MailView: UIViewControllerRepresentable {
    @ObservedObject private var viewStore: ViewStore<MailViewState, MailViewAction>

    init(store: Store<Report, ReportAction>) {
        viewStore = ViewStore(
            store.scope(
                state: \.mail,
                action: ReportAction.mail)
        )
    }

    class Coordinator: NSObject, MFMailComposeViewControllerDelegate {
        @Binding private var isShowing: Bool
        @Binding private var result: MFMailComposeResult?

        private let mail: Mail

        init(isShowing: Binding<Bool>,
             result: Binding<MFMailComposeResult?>,
             mail: Mail)
        {
            _isShowing = isShowing
            _result = result
            self.mail = mail
        }

        func mailComposeController(
            _ controller: MFMailComposeViewController,
            didFinishWith result: MFMailComposeResult,
            error: Error?)
        {
            defer { isShowing = false }
            guard error == nil else {
                self.result = .failed
                return
            }
            self.result = .sent
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(
            isShowing: viewStore.binding(
                get: \.isPresentingMailContent,
                send: MailViewAction.presentMailContentView),
            result: viewStore.binding(
                get: \.mailComposeResult,
                send: MailViewAction.setMailResult),
            mail: viewStore.mail)
    }

    func makeUIViewController(context: UIViewControllerRepresentableContext<MailView>) -> MFMailComposeViewController {
        let vc = MFMailComposeViewController()
        vc.setToRecipients([viewStore.mail.address])
        vc.setSubject(viewStore.mail.subject)
        vc.setMessageBody(viewStore.mail.body, isHTML: false)
        viewStore.mail.attachmentData.enumerated().forEach { index, data in
            vc.addAttachmentData(
                data,
                mimeType: "image/jpeg",
                fileName: "Anhang-\(index + 1)")
        }
        vc.mailComposeDelegate = context.coordinator
        return vc
    }

    func updateUIViewController(
        _ uiViewController: MFMailComposeViewController,
        context: UIViewControllerRepresentableContext<MailView>) {}
}
