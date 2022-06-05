import Foundation
import Styleguide
import SwiftUI

public struct Charge: Hashable, Codable, Identifiable {
  public let id: String
  public let text: String
  public var isFavorite: Bool
  public var isSelected: Bool
  
  public init(id: String, text: String, isFavorite: Bool, isSelected: Bool) {
    self.id = id
    self.text = text
    self.isFavorite = isFavorite
    self.isSelected = isSelected
  }
}

struct ChargeView: View {
  let text: String
  let isSelected: Bool
  let isFavorite: Bool
  let onTap: () -> Void
  let onSwipe: () -> Void
  
  var body: some View {
    HStack {
      if isFavorite {
        Image(systemName: "star.fill")
          .resizable()
          .frame(width: .grid(5), height: .grid(5))
          .foregroundColor(.yellow)
          .accessibilityHidden(true)
      }
      Text(text)
        .foregroundColor(Color(.label))
        .multilineTextAlignment(.leading)
        .accessibilityValue(Text("\(isFavorite ? "favorisiert" : "")"))
      Spacer()
      if isSelected {
        Image(systemName: "checkmark")
          .resizable()
          .frame(width: .grid(4), height: .grid(4))
          .foregroundColor(.blue)
          .accessibilityValue(Text("ausgewählt"))
      }
    }
    .accessibilityAction(named: Text("auswählen")) { onTap() }
    .accessibilityAction(named: Text("favorisieren")) { onSwipe() }
    .accessibilityAddTraits(isSelected ? .isSelected : [])
    .padding(.vertical, .grid(1))
    .contentShape(Rectangle())
    .onTapGesture {
      onTap()
    }
    .swipeActions(allowsFullSwipe: false) {
      Button(
        action: {
          onSwipe()
        },
        label: {
          Image(systemName: "star.fill")
        }
      )
      .tint(.yellow)
    }
  }
}
