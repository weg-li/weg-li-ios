//
//  MailContentView.swift
//  Wegli
//
//  Created by Malte Bünz on 15.06.20.
//  Copyright © 2020 Stefan Trauth. All rights reserved.
//

import MessageUI
import SwiftUI

struct MailContentView: View {
    @State private var result: Result<MFMailComposeResult, Error>? = nil
    @State private var isShowingMailView = false
    
    @EnvironmentObject private var store: AppStore

    var body: some View {
        VStack {
            if MFMailComposeViewController.canSendMail() {
                SubmitButton(state: .readyToSubmit(ordnungsamt: "München")) {
                    self.isShowingMailView.toggle()
                }
            } else {
                Text("Can't send emails from this device")
                    .foregroundColor(.red)
            }
            if result != nil {
                Text("Result: \(String(describing: result))")
                    .lineLimit(nil)
            }
        }
        .sheet(isPresented: $isShowingMailView) {
            MailView(isShowing: self.$isShowingMailView, result: self.$result)
        }
    }
}
