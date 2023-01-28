import Styleguide
import SharedModels
import SwiftUI

struct StatusView: View {
  let status: Notice.Status
  
  var body: some View {
    switch status {
    case .open:
      Label(status.displayTitle, systemImage: "pencil")
        .fontWeight(.semibold)
        .font(.body)
        .foregroundColor(Color(uiColor: .label))
        .padding(.horizontal, 4)
        .padding(.vertical, 2)
        .overlay(
          RoundedRectangle(cornerRadius: 10)
            .stroke(Color(uiColor: .label), lineWidth: 1)
        )
    case .disabled:
      Label(status.displayTitle, systemImage: "circle.slash")
        .fontWeight(.semibold)
        .font(.body)
        .foregroundColor(.white)
        .padding(.horizontal, 4)
        .padding(.vertical, 2)
        .background(Color.red)
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .overlay(
          RoundedRectangle(cornerRadius: 10)
            .stroke(Color(uiColor: .label), lineWidth: 0)
        )
    case .analyzing:
      Label(status.displayTitle, systemImage: "hourglass")
        .fontWeight(.semibold)
        .font(.body)
        .foregroundColor(.white)
        .padding(.horizontal, 4)
        .padding(.vertical, 2)
        .background(Color.init(red: 0.1, green: 0.6, blue: 0.8))
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .overlay(
          RoundedRectangle(cornerRadius: 10)
            .stroke(Color(uiColor: .label), lineWidth: 0)
        )
    case .shared:
      Label(status.displayTitle, systemImage: "checkmark.circle")
        .fontWeight(.semibold)
        .font(.body)
        .foregroundColor(.white)
        .padding(.horizontal, 4)
        .padding(.vertical, 2)
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
