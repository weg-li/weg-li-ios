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
    
    let title: Text
    let state: Status
    let content: AnyView
    @State private var isCollapsed: Bool = false
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                if state == .completed {
                    Image(systemName: "checkmark.circle.fill").foregroundColor(.green)
                } else {
                    Image(systemName: "exclamationmark.circle.fill").foregroundColor(.orange)
                }
                title.fontWeight(.bold)
                Spacer()
                Button(action: {
                    withAnimation {
                        self.isCollapsed.toggle()
                    }
                }) {
                    Image(systemName: "chevron.up.circle")
                        .rotationEffect(.degrees(isCollapsed ? 180 : 0))
                }
                .foregroundColor(.secondary)
            }.font(.title)
            if !isCollapsed {
                content
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: Color(.black).opacity(0.3), radius: 10, x: 0, y: 0)
        .padding()
    }
}

struct Widget_Previews: PreviewProvider {
    static var previews: some View {
        Widget(title: Text("Fotos"), state: .completed, content: AnyView(Text("Foobar")))
    }
}
