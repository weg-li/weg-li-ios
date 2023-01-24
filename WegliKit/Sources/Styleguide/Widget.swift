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
  @State private var showContent = true
  
  public var body: some View {
    VStack(alignment: .leading) {
      HStack {
        CompletionIndicator(isValid: isCompleted)
          .accessibilityHidden(true)
        title.fontWeight(.bold)
          .accessibilitySortPriority(3)
          .accessibilityValue(
            isCompleted
              ? L10n.Widget.A11y.CompletionIndicatorLabel.isValid
              : L10n.Widget.A11y.CompletionIndicatorLabel.isNotValid
          )
        Spacer()
        Button(action: {
          withAnimation(reduceMotion ? nil : .easeOut(duration: 0.2)) {
            self.showContent.toggle()
          }
        }) {
          Image(systemName: "chevron.right.circle")
            .rotationEffect(.degrees(showContent ? 90 : 0))
            .scaleEffect(showContent ? 1.1 : 1)
        }
        .contentShape(Rectangle())
        .accessibility(label: Text(L10n.Widget.A11y.toggleCollapseButtonLabel))
        .accessibilityHidden(true)
        .foregroundColor(.secondary)
      }
      .accessibilityAction(named: Text(L10n.Widget.A11y.toggleCollapseButtonLabel)) {
        self.showContent.toggle()
      }
      .font(.title)
      .padding(.bottom)
      if showContent {
        content().transition(.opacity)
          .accessibilitySortPriority(1)
      }
    }
    .accessibilityElement(children: .contain)
    .padding()
    .background(Color(.secondarySystemFill))
    .clipShape(RoundedRectangle(cornerRadius: 10))
    .padding()
  }
}

struct Widget_Previews: PreviewProvider {
  static var previews: some View {
    NavigationStack {
      VStack {
        Widget(title: Text("Fotos"), isCompleted: false) { Text("Foobar") }
        Widget(title: Text("Fotos"), isCompleted: false) { Text("Foobar") }
        // swiftlint:disable:next line_length
        Widget(title: Text("Fotos"), isCompleted: true) { Text("Turnip greens yarrow ricebean rutabaga endive cauliflower sea lettuce kohlrabi amaranth water spinach avocado daikon napa cabbage asparagus winter purslane kale. Celery potato scallion desert raisin horseradish spinach carrot soko. Lotus root water spinach fennel kombu maize bamboo shoot green bean swiss chard seakale pumpkin onion chickpea gram corn pea. Brussels sprout coriander water chestnut gourd swiss chard wakame kohlrabi beetroot carrot watercress. Corn amaranth salsify bunya nuts nori azuki bean chickweed potato bell pepper artichoke.") }
      }
    }
  }
}
