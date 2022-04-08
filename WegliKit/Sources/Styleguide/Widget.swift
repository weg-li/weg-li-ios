// Created for weg-li in 2021.

import L10n
import SwiftUI

public struct Widget<Content: View>: View {
  @Environment(\.accessibilityReduceMotion) var reduceMotion
  
  public init(
    title: Text,
    isCompleted: Bool,
    content: @escaping () -> Content
  ) {
    self.title = title
    self.isCompleted = isCompleted
    self.content = content
  }
  
  public let title: Text
  public var isCompleted: Bool
  public let content: () -> Content
  @State private var showDetail: Bool = true
  
  public var body: some View {
    VStack(alignment: .leading) {
      HStack {
        CompletionIndicator(isValid: isCompleted)
        title.fontWeight(.bold)
        Spacer()
        Button(action: {
          withAnimation(reduceMotion ? nil : .easeOut(duration: 0.2)) {
            self.showDetail.toggle()
          }
        }) {
          Image(systemName: "chevron.right.circle")
            .rotationEffect(.degrees(showDetail ? 90 : 0))
            .scaleEffect(showDetail ? 1.1 : 1)
        }
        .accessibility(label: Text(L10n.Widget.A11y.toggleCollapseButtonLabel))
        .foregroundColor(.secondary)
      }
      .font(.title)
      .padding(.bottom)
      if showDetail {
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
        // swiftlint:disable:next line_length
        Widget(title: Text("Fotos"), isCompleted: true) { Text("Turnip greens yarrow ricebean rutabaga endive cauliflower sea lettuce kohlrabi amaranth water spinach avocado daikon napa cabbage asparagus winter purslane kale. Celery potato scallion desert raisin horseradish spinach carrot soko. Lotus root water spinach fennel kombu maize bamboo shoot green bean swiss chard seakale pumpkin onion chickpea gram corn pea. Brussels sprout coriander water chestnut gourd swiss chard wakame kohlrabi beetroot carrot watercress. Corn amaranth salsify bunya nuts nori azuki bean chickweed potato bell pepper artichoke.") }
      }
    }
    //        .environment(\.colorScheme, .dark)
  }
}
