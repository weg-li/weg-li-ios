//
//  Widget.swift
//  Wegli
//
//  Created by Stefan Trauth on 08.10.19.
//  Copyright © 2019 Stefan Trauth. All rights reserved.
//

import SwiftUI

struct Widget<Content: View>: View {
    let title: Text
    var isCompleted: Bool
    let content: () -> Content
    @State private var isCollapsed: Bool = false
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                completionIndicator()
                title.fontWeight(.bold)
                Spacer()
                Button(action: {
                    withAnimation(.spring()) {
                        self.isCollapsed.toggle()
                    }
                }) {
                    Image(systemName: "chevron.up.circle")
                        .rotationEffect(.degrees(isCollapsed ? 180 : 0))
                }
                .foregroundColor(.secondary)
            }.font(.title)
            if !isCollapsed {
                content().transition(.opacity)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: Color(.black).opacity(0.3), radius: 10, x: 0, y: 0)
        .padding()
    }
    
    private func completionIndicator() -> some View {
        if isCompleted {
            return Image(systemName: "checkmark.circle.fill").foregroundColor(.green)
        } else {
            return Image(systemName: "exclamationmark.circle.fill").foregroundColor(.orange)
        }
    }
}

struct Widget_Previews: PreviewProvider {
    static var previews: some View {
        Widget(title: Text("Fotos"), isCompleted: false) { Text("Foobar") }
    }
}
