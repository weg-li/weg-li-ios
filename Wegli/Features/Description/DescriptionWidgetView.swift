//
//  DescriptionWidgetView.swift
//  Wegli
//
//  Created by Malte Bünz on 14.06.20.
//  Copyright © 2020 Stefan Trauth. All rights reserved.
//

import SwiftUI

struct DescriptionWidgetView: View {
    @EnvironmentObject private var appStore: AppStore
    
    @State private var edit = false
    
    var body: some View {
        VStack(alignment: .leading) {
            VStack(alignment: .leading, spacing: 4) {
                row(title: "Marke:", content: appStore.state.report.car.type ?? "")
                row(title: "Farbe:", content: appStore.state.report.car.color ?? "")
                row(title: "Kennzeichen:", content: appStore.state.report.car.licensePlateNumber ?? "")
                row(title: "Dauer:", content: appStore.state.report.charge.time.description)
                row(title: "Art des Verstoßes:", content: appStore.state.report.charge.humandReadableCharge)
                if appStore.state.report.charge.blockedOthers {
                    HStack {
                        Text("Behinderung anderer Verkehrsteilnehmer")
                            .bold()
                        Spacer()
                        Image(systemName: "checkmark.circle.fill").foregroundColor(.green)
                    }
                }
            }
            HStack {
                Button(action: {
                    self.edit.toggle()
                }) {
                    HStack {
                        Image(systemName: "pencil")
                        Text("Beschreibung bearbeiten")
                    }
                }
                .buttonStyle(EditButtonStyle())
                Spacer()
            }
        }
        .sheet(isPresented: $edit) {
            Description(isPresented: self.$edit, viewModel: .init(model: self.appStore.state.report))
                .environmentObject(self.appStore)
        }
    }
    
    private func row(title: String, content: String) -> some View {
        VStack(alignment: .leading) {
            Text(title)
                .bold()
            Text(content)
        }
    }
}

struct DescriptionWidgetView_Previews: PreviewProvider {
    static var previews: some View {
        Widget(
            title: Text("Beschreibung"),
            isCompleted: true) {
                DescriptionWidgetView()
        }
    }
}
