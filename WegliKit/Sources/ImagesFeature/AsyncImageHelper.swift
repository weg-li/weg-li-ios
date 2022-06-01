// adopted sample code to use async/await from apples example code of https://developer.apple.com/wwdc21/10076

import AVFoundation
import Combine
import Foundation
import SwiftUI

/// This class handles image loading for a single image and its corresponding thumbnail. It loads images
/// asynchronously in the background and publishes to Combine when it finishes loading a file, or if it
/// encounters an error while loading.
@MainActor
class AsyncImageStore: ObservableObject {
  var url: URL
  
  /// When the store finishes loading the thumbnail, this property contains the thumbnail. If the store
  /// hasn't finished loading the thumbnail, this property contains a placeholder image.
  @Published var thumbnailImage: UIImage
  
  /// When the store is finished loading the full-size image, this property contains the full-size image. If
  /// the store hasn't finished loading the full-size image, this property contains a placeholder image.
  @Published var image: UIImage
  
  private var subscriptions: Set<AnyCancellable> = []
  
  private let errorImage: UIImage
  
  private let imageLoader: ImageLoader
  
  /// This initializes a data store object that loads a specified image and its corresponding thumbnail.
  /// When the store begins loading images, it publishes `loadingImage`. If the store fails to load
  /// the thumbnail or image, it publishes `errorImage`. The store doesn't start loading an image
  /// until the first time your code accesses one of the image properties.
  init(
    url: URL,
    imageLoader: ImageLoader = ImageLoader(),
    loadingImage: UIImage = UIImage(systemName: "rectangle.fill")!.withTintColor(.gray),
    errorImage: UIImage = UIImage(systemName: "xmark.circle")!
  ) {
    self.url = url
    self.imageLoader = imageLoader
    self.thumbnailImage = loadingImage
    self.image = loadingImage
    self.errorImage = errorImage
  }
  
  /// This method starts an asynchronous load of the thumbnail image. If this method doesn't find an
  /// image at the specified URL, it publishes an error image.
  func loadThumbnail() async {
    do {
      self.thumbnailImage = try await imageLoader.loadThumbnail(url: url)
    } catch {
      debugPrint(#function, "failed ❌")
    }
  }
  
  /// This method starts an asynchronous load of the full-size image. If it doesn't find an image at the
  /// specified URL, it publishes an error image.
  func loadImage() async {
    do {
      self.image = try await imageLoader.loadImage(url: url)
    } catch {
      debugPrint(#function, "failed ❌")
    }
  }
}

/// This view displays a thumbnail from a URL. It begins loading the thumbnail asynchronously when
/// it first appears on screen. While loading, this view displays a placeholder image. If it encounters an error,
/// it displays an error image. You must call the `load()` function to start asynchronous loading.
struct AsyncThumbnailView: View {
  let url: URL
  let contentMode: ContentMode
  
  @StateObject private var imageStore: AsyncImageStore
  
  init(url: URL, contentMode: ContentMode = .fill) {
    self.url = url
    self.contentMode = contentMode
    
    // Initialize the image store with the provided URL.
    _imageStore = StateObject(wrappedValue: AsyncImageStore(url: url))
  }
  
  var body: some View {
    Image(uiImage: imageStore.thumbnailImage)
      .resizable()
      .aspectRatio(contentMode: contentMode)
      .task {                     
        await imageStore.loadThumbnail()
      }
  }
}

struct AsyncImageView: View {
  let url: URL
  @StateObject private var imageStore: AsyncImageStore
  
  init(url: URL) {
    self.url = url
    
    _imageStore = StateObject(wrappedValue: AsyncImageStore(url: url))
  }
  
  var body: some View {
    Image(uiImage: imageStore.image)
      .resizable()
      .aspectRatio(contentMode: .fill)
      .task {
        await imageStore.loadImage()
      }
  }
}
