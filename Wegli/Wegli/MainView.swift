//
//  MainView.swift
//  Wegli
//
//  Created by Stefan Trauth on 08.10.19.
//  Copyright © 2019 Stefan Trauth. All rights reserved.
//

import SwiftUI

struct MainView: View {
    @State private var showReportForm: Bool = false

    private let recognizer = NumberPlateRecognizerService.sharedInstance
    
    var body: some View {
        VStack {
            Spacer()
            Button(action: {
                self.showReportForm.toggle()
            }) {
                VStack {
                    Image(systemName: "plus.circle.fill")
                    Text("Neue Anzeige")
                }
                .font(.headline)
            }


            Button(action: {
                print("Scan Example Images Bulk")
                self.recognizer.setConfidenceDelimiter(value: 90.0)
                self.recognizer.scanExampleImagesBulk()
            }) {
                VStack {
                    Image(systemName: "plus.circle.fill")
                    Text("Scan Example Images Bulk")
                }.font(.subheadline)
            }

            Button(action: {
                print("Scan Example Images")
                self.recognizer.setConfidenceDelimiter(value: 90.0)
                self.recognizer.scanExampleImages()
            }) {
                VStack {
                    Image(systemName: "plus.circle.fill")
                    Text("Scan Example Images")
                }.font(.subheadline)
            }




            Button(action: {
                print("Scanner Log Contents: \n \(self.recognizer.scannedNumberPlatesLog)")
            }) {
                VStack {
                    Text("Print Scanner Log")
                }.font(.title)
            }
            
            Spacer()
            Text("Du hast bereits 30 Anzeigen versendet.").foregroundColor(.secondary)
        }
        .sheet(isPresented: $showReportForm) {
            ReportForm()
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
