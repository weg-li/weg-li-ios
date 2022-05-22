// Created for weg-li in 2021.

import DescriptionFeature
import Helper
import ReportFeature
import SharedModels
import Styleguide
import SwiftUI

public struct NoticeView: View {
 public let notice: Notice
  
  public var body: some View {
    ZStack {
      HStack {
        VStack(alignment: .leading) {
          Text(notice.createdAt.humandReadableDate)
            .fontWeight(.bold)
            .font(.title)
            .padding(.bottom, .grid(1))
          
          HStack(spacing: .grid(3)) {
            Image(systemName: "waveform.path.ecg")
              .font(.title2)
              .accessibility(hidden: true)
            
            VStack(alignment: .leading, spacing: .grid(1)) {
              Text("Status: __\(notice.status)__")
            }
            .font(.body)
          }
          .accessibility(label: Text("Status"))
          .accessibilityElement()
          .padding(.bottom, .grid(2))
          
          HStack(spacing: .grid(3)) {
            Image(systemName: "car")
              .font(.title2)
              .accessibility(hidden: true)
            
            VStack(alignment: .leading, spacing: .grid(1)) {
              Text(verbatim: notice.registration)
                .font(.custom(FontName.nummernschild.rawValue, size: 22, relativeTo: .body))
                .foregroundColor(Color(.label))
                .textCase(.uppercase)
              
              VStack(alignment: .leading) {
                Text("Marke: __\(notice.brand)__")
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
          
          HStack(spacing: .grid(3)) {
            Image(systemName: "exclamationmark.triangle")
              .font(.title2)
              .accessibility(hidden: true)
          
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
            }
            .font(.body)
          }
          .accessibility(label: Text("report info"))
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
