//
//  Widget.swift
//  Wegli
//
//  Created by Stefan Trauth on 08.10.19.
//  Copyright © 2019 Stefan Trauth. All rights reserved.
//

import SwiftUI

struct Widget: View {
    enum Status {
        case incomplete
        case completed
    }
    
    let content: AnyView
    let title: Text
    let state: Status
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                if state == .completed {
                    Image(systemName: "checkmark.circle.fill").foregroundColor(.green)
                } else {
                    Image(systemName: "exclamationmark.circle.fill").foregroundColor(.orange)
                }
                title
                Spacer()
            }.font(.largeTitle)
            content
        }
        .padding()
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: Color(.lightGray), radius: 20, x: 0, y: 0)
        .padding()
    }
}

struct Widget_Previews: PreviewProvider {
    static var previews: some View {
        Widget(content: AnyView(Text("Foobar")), title: Text("Fotos"), state: .completed)
    }
}
