//
//  ContentView.swift
//  Wegli
//
//  Created by Stefan Trauth on 08.10.19.
//  Copyright © 2019 Stefan Trauth. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            SubmitButton(state: .readyToSubmit(ordnungsamt: "München"))
            SubmitButton(state: .unsupportedLocation)
            SubmitButton(state: .missingData)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
