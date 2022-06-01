// Created for weg-li in 2021.

import DescriptionFeature
import Helper
import ReportFeature
import SharedModels
import Styleguide
import SwiftUI

public struct NoticeView: View {
  public let notice: Notice
  
  @Environment(\.dynamicTypeSize) private var dynamicTypeSize
  @Environment(\.horizontalSizeClass) var horizontalSizeClass
  var useVStackOverall: Bool {
    dynamicTypeSize > .accessibility2 && horizontalSizeClass == .compact
  }
  
  public var body: some View {
    ZStack {
      HStack {
        VStack(alignment: .leading) {
          Text(notice.createdAt.humandReadableDate)
            .fontWeight(.bold)
            .font(.title)
            .padding(.bottom, .grid(1))
          
          HVStack(useVStack: useVStackOverall, spacing: .grid(3)) {
            Image(systemName: "waveform.path.ecg")
              .font(.title2)
              .accessibility(hidden: true)
              .unredacted()
            
            VStack(alignment: .leading, spacing: .grid(1)) {
              Text("Status: __\(notice.status)__")
            }
            .font(.body)
          }
          .accessibility(label: Text("Status"))
          .accessibilityElement()
          .padding(.bottom, .grid(2))
          
          HVStack(useVStack: useVStackOverall, spacing: .grid(3)) {
            Image(systemName: "car")
              .font(.title2)
              .accessibility(hidden: true)
              .unredacted()
            
            VStack(alignment: .leading, spacing: .grid(1)) {
              if let registration = notice.registration {
                HStack(alignment: .center, spacing: 3) {
                  Text(verbatim: registration)
                    .font(.custom(FontName.nummernschild.rawValue, size: 23 , relativeTo: .body))
                    .foregroundColor(.black)
                    .textCase(.uppercase)
                    .padding(EdgeInsets(top: 2, leading: 8, bottom: 2, trailing: 2))
                    .overlay(Color.blue.frame(width: 6), alignment: .leading)
                }
                .unredacted()
                .background(.white)
                .clipShape(
                  RoundedRectangle(cornerRadius: 4, style: .circular)
                )
                .overlay(
                  RoundedRectangle(cornerRadius: 4)
                    .stroke(Color.black, lineWidth: 1)
                )
                .accessibility(value: Text(registration))
              }
              
              VStack(alignment: .leading) {
                if let brand = notice.brand {
                  Text("Marke: __\(brand)__")
                }
                if let color = notice.displayColor {
                  Text("Farbe: __\(color)__")
                }
              }
            }
            .font(.body)
          }
          .accessibility(label: Text("Vehicle info"))
          .accessibilityElement()
          .padding(.bottom, .grid(2))
          
          HVStack(useVStack: useVStackOverall, spacing: .grid(3)) {
            Image(systemName: "exclamationmark.triangle")
              .font(.title2)
              .accessibility(hidden: true)
              .unredacted()
            
            VStack(alignment: .leading, spacing: .grid(1)) {
              VStack(alignment: .leading) {
                if let time = notice.time?.description {
                  Text(time)
                }
                if let interval = notice.interval {
                  Text(interval)
                }
              }
              Text(notice.charge)
                .multilineTextAlignment(.leading)
                .fixedSize(horizontal: false, vertical: true)
            }
            .font(.body)
          }
          .accessibilityElement()
        }
        .padding()
        Spacer()
      }
      .background(
        Color(.systemGray6)
          .clipShape(RoundedRectangle(cornerRadius: 10))
      )
      .padding(.bottom)
      
      VStack {
        HStack {
          Spacer()
          Image(systemName: "exclamationmark.octagon")
            .font(.system(size: 140))
            .offset(x: 70)
            .clipped()
            .blendMode(.overlay)
            .unredacted()
        }
        Spacer()
      }
      .accessibility(hidden: true)
    }
    .clipShape(RoundedRectangle(cornerRadius: 10))
    .accessibilityElement(children: .combine)
  }
}

struct NoticeView_Previews: PreviewProvider {
  static var previews: some View {
    Preview {
      NoticeView(notice: .mock)
    }
  }
}
