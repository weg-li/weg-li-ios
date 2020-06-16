//
//  Widget.swift
//  Wegli
//
//  Created by Stefan Trauth on 08.10.19.
//  Copyright © 2019 Stefan Trauth. All rights reserved.
//

import SwiftUI

struct Widget<Content: View>: View {
    @Environment(\.colorScheme) private var scheme: ColorScheme
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
        .background(backgroundColor)
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .shadow(radius: 10)
        .padding()
    }
    
    private var backgroundColor: Color {
        scheme == .dark ? Color(white: 30 / 255) : Color(.systemBackground)
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
        NavigationView {
            VStack {
                Widget(title: Text("Fotos"), isCompleted: false) { Text("Foobar") }
                Widget(title: Text("Fotos"), isCompleted: false) { Text("Foobar") }
                Widget(title: Text("Fotos"), isCompleted: true) { Text("Turnip greens yarrow ricebean rutabaga endive cauliflower sea lettuce kohlrabi amaranth water spinach avocado daikon napa cabbage asparagus winter purslane kale. Celery potato scallion desert raisin horseradish spinach carrot soko. Lotus root water spinach fennel kombu maize bamboo shoot green bean swiss chard seakale pumpkin onion chickpea gram corn pea. Brussels sprout coriander water chestnut gourd swiss chard wakame kohlrabi beetroot carrot watercress. Corn amaranth salsify bunya nuts nori azuki bean chickweed potato bell pepper artichoke.") }
            }
        }
//        .environment(\.colorScheme, .dark)
    }
}
