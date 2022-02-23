import Combine
import CoreGraphics
import CoreImage
import Dispatch
import Foundation
import os
import SwiftUI
import UIKit

private let logger = Logger(subsystem: "li.weg.iosClient", category: "ImageLoader")

/// This helper class asynchronously loads thumbnails and full-size images from a file URL.
actor ImageLoader {
  enum Error: Swift.Error {
    case noSuchUrl
    case noThumbnail
    case noImage
    case unknownError(Swift.Error)
  }
  
  private enum LoaderStatus {
    case inProgress(Task<UIImage, Swift.Error>)
    case fetched(UIImage)
  }
  
  private var images: [URL: LoaderStatus] = [:]
  
  func loadImage(url: URL) async throws -> UIImage {
    if let status = images[url] {
      switch status {
      case .fetched(let image):
        return image
      case .inProgress(let task):
        return try await task.value
      }
    }
    
    do {
      logger.debug("Loading image: \(url.path)...")
      
      let task = Task { () -> UIImage in
        let image = try await loadThumbnailSynchronously(url: url)
        logger.debug("... done loading thumbnail: \(url.path)...")
        return image
      }
      images[url] = .inProgress(task)
      let image = try await task.value
      images[url] = .fetched(image)
      return image
      
    } catch let (error) {
      if let loaderError = error as? ImageLoaderError {
        debugPrint(loaderError.errorDescription ?? loaderError.localizedDescription)
        throw loaderError
      } else {
        debugPrint(error.localizedDescription)
        throw error
      }
    }
  }
  
  func loadThumbnail(url: URL) async throws -> UIImage {
    if let status = images[url] {
      switch status {
      case .fetched(let image):
        return image
      case .inProgress(let task):
        return try await task.value
      }
    }
    
    do {
      logger.debug("Loading thumbnail: \(url.path)...")
      
      let task = Task { () -> UIImage in
        let image = try await loadThumbnailSynchronously(url: url)
        logger.debug("... done loading thumbnail: \(url.path)...")
        return image
      }
      images[url] = .inProgress(task)
      let image = try await task.value
      images[url] = .fetched(image)
      return image
    } catch let (error) {
      if let loaderError = error as? ImageLoaderError {
        debugPrint(loaderError.errorDescription ?? loaderError.localizedDescription)
        throw loaderError
      } else {
        debugPrint(error.localizedDescription)
        throw error
      }
    }
  }
  
  /// This method synchronously loads the embedded thumbnail. If it can't load the thumbnail, it returns `nil`.
  private func loadThumbnailSynchronously(url: URL) async throws -> UIImage {
    try await withCheckedThrowingContinuation { continuation in
      guard let imageSource = CGImageSourceCreateWithURL(url as CFURL, nil) else {
        let msg = "Error in CGImageSourceCreateWithURL for \(url.path)"
        logger.error("\(msg)")
        continuation.resume(throwing: Error.noSuchUrl)
        return
      }
      let thumbnailOptions = [
        kCGImageSourceCreateThumbnailFromImageAlways: true,
        kCGImageSourceCreateThumbnailWithTransform: true,
        kCGImageSourceThumbnailMaxPixelSize: 600
      ] as CFDictionary
      guard let cgImage = CGImageSourceCreateThumbnailAtIndex(imageSource, 0, thumbnailOptions) else {
        let msg = "Error in CGImageSourceCreateThumbnailAtIndex for \(url.path)"
        logger.error("\(msg)")
        continuation.resume(throwing: Error.noThumbnail)
        return
      }
      let image = UIImage(cgImage: cgImage)
      continuation.resume(returning: image)
    }
  }
  
  /// This method synchronously loads the embedded image. If it can't load the image, it returns `nil`.
  private func loadImageSynchronously(url: URL) async throws -> UIImage {
    try await withCheckedThrowingContinuation { continuation in
      guard let imageSource = CGImageSourceCreateWithURL(url as CFURL, nil) else {
        let msg = "Error in CGImageSourceCreateWithURL for \(url.path)"
        logger.error("\(msg)")
        continuation.resume(throwing: Error.noSuchUrl)
        return
      }
      guard let cgImage = CGImageSourceCreateImageAtIndex(imageSource, 0, nil) else {
        let msg = "Error in CGImageSourceCreateImageAtIndex for \(url.path)"
        logger.error("\(msg)")
        continuation.resume(throwing: Error.noImage)
        return
      }
      let image = UIImage(cgImage: cgImage)
      continuation.resume(returning: image)
    }
  }
  
}


struct ImageLoaderError: Swift.Error, LocalizedError {
  let errorDump: String
  let file: String
  let line: UInt
  let message: String
  
  public init(
    error: Error,
    file: StaticString = #fileID,
    line: UInt = #line
  ) {
    var string = ""
    dump(error, to: &string)
    self.errorDump = string
    self.file = String(describing: file)
    self.line = line
    self.message = error.localizedDescription
  }
  
  public var errorDescription: String? {
    self.message
  }
}
