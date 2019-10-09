//
//  ReportForm.swift
//  Wegli
//
//  Created by Stefan Trauth on 08.10.19.
//  Copyright © 2019 Stefan Trauth. All rights reserved.
//

import SwiftUI

struct ReportForm: View {
    var body: some View {
        VStack {
            Widget(title: Text("Fotos"), state: .completed, content: AnyView(Text("Foobar")))
            SubmitButton(state: .readyToSubmit(ordnungsamt: "München")) {}
            DiscardButton() {}
        }
    }
}

struct ReportForm_Previews: PreviewProvider {
    static var previews: some View {
        ReportForm()
    }
}
