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
            VStack(alignment: .leading) {
                row(title: "Marke:", content: appStore.state.report.car.type ?? "")
                row(title: "Farbe:", content: appStore.state.report.car.color ?? "")
                row(title: "Kennzeichen:", content: appStore.state.report.car.licensePlateNumber ?? "")
            }
            VStack(alignment: .leading) {
                row(title: "Dauer:", content: appStore.state.report.crime.duration ?? "")
                row(title: "Art des Verstoßes:", content: appStore.state.report.crime.type ?? "")
                if appStore.state.report.crime.blockedOthers {
                    HStack {
                        Text("Behinderung anderer Verkehrsteilnehmer")
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
        .onAppear { print("🍏", self.appStore.state.report) }
        .sheet(isPresented: $edit) {
            Description(isPresented: self.$edit, viewModel: .init(model: self.appStore.state.report))
                .environmentObject(self.appStore)
        }
    }
    
    private func row(title: String, content: String) -> some View {
        HStack {
            Text(title)
            Spacer()
            Text(content)
                .bold()
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
