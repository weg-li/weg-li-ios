//
//  MailContentView.swift
//  weg-li
//
//  Created by Malte Bünz on 15.06.20.
//  Copyright © 2020 Stefan Trauth. All rights reserved.
//

import MessageUI
import SwiftUI

struct MailContentView: View {
    @EnvironmentObject private var store: AppStore
    @State private var result: Result<MFMailComposeResult, Error>?
    @State private var isShowingMailView = false

    var body: some View {
        VStack {
            if MFMailComposeViewController.canSendMail() {
                SubmitButton(state: .readyToSubmit(ordnungsamt: store.state.report.district?.name ?? "")) {
                    print(self.store.state.report)
                    self.isShowingMailView.toggle()
                }
            } else {
                Text("Auf diesem Gerät können leider keine E-Mails versendet werden!")
                    .foregroundColor(.red)
            }
            if result != nil {
                Text("Result: \(String(describing: result))")
                    .lineLimit(nil)
            } else {}
        }
        .sheet(isPresented: $isShowingMailView) {
            MailView(isShowing: self.$isShowingMailView, result: self.$result, report: self.store.state.report, contact: self.store.state.contact)
        }
    }
}

struct MailContentView_Previews: PreviewProvider {
    static var previews: some View {
        MailContentView()
    }
}
