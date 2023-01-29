// adopted sample code to use async/await from apples example code of https://developer.apple.com/wwdc21/10076

import AVFoundation
import Combine
import Foundation
import Kingfisher
import SwiftUI

/// This view displays a thumbnail from a URL. It begins loading the thumbnail asynchronously when
/// it first appears on screen. While loading, this view displays a placeholder image. If it encounters an error,
/// it displays an error image. You must call the `load()` function to start asynchronous loading.
public struct AsyncThumbnailView: View {
  let url: URL
  private let processor = DownsamplingImageProcessor(size: .init(width: 600, height: 600))
  |> RoundCornerImageProcessor(cornerRadius: 10)
  
  @State private var image: UIImage?
  
  public init(url: URL) {
    self.url = url
  }
  
  public var body: some View {
    KFImage.url(url)
      .placeholder { placeholder }
      .setProcessor(processor)
      .fade(duration: 0.25)
  }
  
  var placeholder: some View {
    Rectangle()
      .fill(.gray)
      .overlay {
        ProgressView()
          .progressViewStyle(CircularProgressViewStyle(tint: .white))
      }
  }
}

struct AsyncImageView: View {
  let url: URL
  @State private var image: UIImage?
  
  init(url: URL) {
    self.url = url
  }
  
  var body: some View {
    KFImage.url(url)
      .placeholder { placeholder }
      .fade(duration: 0.25)
  }
  
  var placeholder: some View {
    Rectangle()
      .fill(.gray)
      .overlay {
        ProgressView()
          .progressViewStyle(CircularProgressViewStyle(tint: .white))
      }
  }
}
