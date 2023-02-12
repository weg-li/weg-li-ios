import Styleguide
import SharedModels
import SwiftUI

struct StatusView: View {
  let status: Notice.Status
  
  var body: some View {
    switch status {
    case .open:
      HStack(spacing: 3) {
        Image(systemName: "pencil")
        Text(status.displayTitle)
      }
      .fontWeight(.semibold)
      .font(.body)
      .foregroundColor(Color(uiColor: .label))
      .padding(.horizontal)
      .padding(.vertical, 4)
      .overlay(
        RoundedRectangle(cornerRadius: 10)
          .stroke(Color(uiColor: .label), lineWidth: 1)
      )
    case .disabled:
      HStack(spacing: 3) {
        Image(systemName: "circle.slash")
        Text(status.displayTitle)
      }
      .fontWeight(.semibold)
      .font(.body)
      .foregroundColor(.white)
      .padding(.horizontal)
      .padding(.vertical, 4)
      .background(Color.red)
      .clipShape(RoundedRectangle(cornerRadius: 10))
      .overlay(
        RoundedRectangle(cornerRadius: 10)
          .stroke(Color(uiColor: .label), lineWidth: 0)
      )
    case .analyzing:
      HStack(spacing: 3) {
        Image(systemName: "hourglass")
        Text(status.displayTitle)
      }
      .fontWeight(.semibold)
      .font(.body)
      .foregroundColor(.white)
      .padding(.horizontal)
      .padding(.vertical, 4)
      .background(Color.init(red: 0.1, green: 0.6, blue: 0.8))
      .clipShape(RoundedRectangle(cornerRadius: 10))
      .overlay(
        RoundedRectangle(cornerRadius: 10)
          .stroke(Color(uiColor: .label), lineWidth: 0)
      )
    case .shared:
      HStack(spacing: 3) {
        Image(systemName: "checkmark.circle")
        Text(status.displayTitle)
      }
      .fontWeight(.semibold)
      .font(.body)
      .foregroundColor(.white)
      .padding(.vertical, 4)
      .padding(.horizontal)
      .background(Color.green)
      .clipShape(RoundedRectangle(cornerRadius: 10))
      .overlay(
        RoundedRectangle(cornerRadius: 10)
          .stroke(Color(uiColor: .label), lineWidth: 0)
      )
    }
  }
}

struct StatusView_Previews: PreviewProvider {
  static var previews: some View {
    VStack {
      StatusView(status: .open)
      StatusView(status: .disabled)
      StatusView(status: .analyzing)
      StatusView(status: .shared)
    }
  }
}
