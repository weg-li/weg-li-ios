import Foundation
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
  
  var body: some View {
    HStack {
      if isFavorite {
        Image(systemName: "star.fill")
          .resizable()
          .frame(width: 15, height: 15)
          .foregroundColor(.yellow)
      }
      Text(text)
        .foregroundColor(Color(.label))
        .multilineTextAlignment(.leading)
      Spacer()
      if isSelected {
        Image(systemName: "checkmark")
          .resizable()
          .frame(width: 15, height: 15)
          .foregroundColor(.wegliBlue)
      }
    }
  }
}
