// Created for weg-li in 2021.

import SwiftUI

struct Widget<Content: View>: View {
    let title: Text
    var isCompleted: Bool
    let content: () -> Content
    @State private var isCollapsed: Bool = false

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                CompletionIndicator(isValid: isCompleted)
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
                .accessibility(label: Text(L10n.Widget.A11y.toggleCollapseButtonLabel))
                .foregroundColor(.secondary)
            }
            .font(.title)
            .padding(.bottom)
            if !isCollapsed {
                content().transition(.opacity)
            }
        }
        .padding()
        .background(Color(.secondarySystemFill))
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .padding()
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
