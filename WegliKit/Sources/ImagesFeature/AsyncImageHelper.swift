// adopted sample code to use async/await from apples example code of https://developer.apple.com/wwdc21/10076

import AVFoundation
import Combine
import Foundation
import SwiftUI

/// This view displays a thumbnail from a URL. It begins loading the thumbnail asynchronously when
/// it first appears on screen. While loading, this view displays a placeholder image. If it encounters an error,
/// it displays an error image. You must call the `load()` function to start asynchronous loading.
struct AsyncThumbnailView: View {
  let url: URL
  let contentMode: ContentMode
  
  private let imageLoader: ImageActor.ImageLoader
  
  @State private var image: UIImage?
  
  init(url: URL, contentMode: ContentMode = .fill) {
    self.url = url
    self.contentMode = contentMode
    self.imageLoader = ImageActor.shared
  }
  
  var body: some View {
    Group {
      if let image {
        Image(uiImage: image)
          .resizable()
          .aspectRatio(contentMode: .fill)
      } else {
        Rectangle()
          .fill(.gray)
          .overlay {
            ProgressView()
              .progressViewStyle(CircularProgressViewStyle(tint: .white))
          }
      }
    }
    .task {
      do {
        image = try await imageLoader.loadThumbnail(url: url)
      } catch {
        debugPrint(#function, "failed ❌")
      }
    }
  }
}

struct AsyncImageView: View {
  let url: URL
  @State private var image: UIImage?
  private let imageLoader: ImageActor.ImageLoader
  
  init(url: URL) {
    self.url = url
    self.imageLoader = ImageActor.shared
  }
  
  var body: some View {
    Group {
      if let image {
        Image(uiImage: image)
          .resizable()
          .aspectRatio(contentMode: .fill)
      } else {
        Rectangle()
          .fill(.gray)
          .overlay {
            ProgressView()
              .progressViewStyle(CircularProgressViewStyle(tint: .white))
          }
      }
    }
    .task {
      do {
        image = try await imageLoader.loadImage(url: url)
      } catch {
        debugPrint(#function, "failed ❌")
      }
    }
  }
}
