// Created for weg-li in 2021.

import DescriptionFeature
import Helper
import ImagesFeature
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
          if let noticeDate = notice.date {
            Text("Tatzeit: \(noticeDate.humandReadableDate)")
              .fontWeight(.bold)
              .font(.title)
              .padding(.bottom, .grid(1))
          }
          
          if let registration = notice.registration {
            HStack(alignment: .center, spacing: 3) {
              Text(verbatim: registration)
                .font(.custom(FontName.nummernschild.rawValue, size: 23, relativeTo: .body))
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
          
          if let photos = notice.photos {
            HVStack(useVStack: useVStackOverall, spacing: .grid(3)) {
              ImageGrid {
                ForEach(photos, id: \.self) { photo in
                  if let url = URL(string: photo.url) {
                    AsyncThumbnailView(url: url)
                      .frame(
                        minWidth: 50,
                        maxWidth: .infinity,
                        minHeight: 100,
                        maxHeight: 100
                      )
                      .clipShape(RoundedRectangle(cornerRadius: 10))
                      .padding(.grid(1))
                  }
                }
              }
            }
            .accessibilityElement()
          }
          
          HVStack(useVStack: useVStackOverall, spacing: .grid(3)) {
            Text("Status:")
              .font(.subheadline)
              .fontWeight(.semibold)
            
            VStack(alignment: .leading, spacing: .grid(1)) {
              if let status = notice.status {
                StatusView(status: status)
              }
            }
            .font(.body)
          }
          .accessibilityElement(children: .combine)
          .padding(.bottom, .grid(2))
          
          if let creationDate = notice.createdAt {
            Text("Erstellt am: \(creationDate.humandReadableDate)")
              .font(.subheadline)
              .padding(.bottom, .grid(1))
          }
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
