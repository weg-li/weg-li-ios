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
        ScrollView {
            VStack {
                Widget(title: Text("Fotos"), state: .completed, content: AnyView(Images()))
                Widget(title: Text("Ort"), state: .completed, content: AnyView(Location()))
                Widget(title: Text("Beschreibung"), state: .completed, content: AnyView(Description()))
                Widget(title: Text("Persönliche Daten"), state: .completed, content: AnyView(PersonalData()))
                SubmitButton(state: .readyToSubmit(ordnungsamt: "München")) {}
                DiscardButton() {}
            }
        }
    }
}

struct ReportForm_Previews: PreviewProvider {
    static var previews: some View {
        ReportForm()
    }
}
