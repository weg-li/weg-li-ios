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
    
    var body: some View {
        VStack {
            Button(action: {
                self.showReportForm.toggle()
            }) {
                VStack {
                    Image(systemName: "plus.circle.fill")
                    Text("Neue Anzeige")
                }
                .font(.headline)
            }
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
