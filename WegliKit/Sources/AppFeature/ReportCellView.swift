// Created for weg-li in 2021.

import DescriptionFeature
import Helper
import ReportFeature
import SwiftUI

public struct ReportCellView: View {
  public let report: Report
  
  public var body: some View {
    ZStack {
      HStack {
        VStack(alignment: .leading) {
          Text(report.date.humandReadableDate)
            .fontWeight(.bold)
            .font(.title)
            .padding(.bottom, 4)
          HStack(spacing: 12) {
            Image(systemName: "car")
              .font(.title2)
              .accessibility(hidden: true)
            VStack(alignment: .leading, spacing: 4) {
              Text("\(DescriptionState.brands[report.description.selectedBrand]), \(DescriptionState.colors[report.description.selectedColor].value)")
              Text(verbatim: report.description.licensePlateNumber)
            }
            .font(.body)
          }
          .accessibility(label: Text("Vehicle info"))
          .accessibilityElement()
          .padding(.bottom, 6)
          HStack(spacing: 12) {
            Image(systemName: "exclamationmark.triangle")
              .font(.title2)
              .accessibility(hidden: true)
            VStack(alignment: .leading, spacing: 4) {
              Text(report.description.time)
              Text(DescriptionState.charges[report.description.selectedType].value)
            }
            .font(.body)
          }
          .accessibility(label: Text("report info"))
          .accessibilityElement()
        }
        .padding()
        Spacer()
      }
      .background(Color(.systemGray6))
      .padding(.bottom)
      // Design attempt :D
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
  }
}

struct ReportCellView_Previews: PreviewProvider {
  static var previews: some View {
    Preview {
      ReportCellView(report: .preview)
    }
  }
}
