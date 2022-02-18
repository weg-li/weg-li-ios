// Created for weg-li in 2021.

import Combine
import CoreLocation
import ImageConverter
import os.log
import PhotosUI
import SharedModels
import SwiftUI

public struct ImagePicker: UIViewControllerRepresentable {
  @Binding var isPresented: Bool
  @Binding var pickerResult: [StorableImage?]
  @Binding var coordinate: CLLocationCoordinate2D?
  
  
  public class Coordinator: NSObject, PHPickerViewControllerDelegate {
    let parent: ImagePicker
    let converter: ImageConverter = .live()
    let converterQueue = DispatchQueue(label: "li.weg.iOS-Client.ConverterQueue")
    var bag: Set<AnyCancellable> = .init()
    
    public init(_ parent: ImagePicker) {
      self.parent = parent
    }
    
    public func picker(
      _ picker: PHPickerViewController,
      didFinishPicking results: [PHPickerResult]
    ) {
      guard !results.isEmpty else {
        parent.isPresented = false
        return
      }
      
      for result in results {
        let prov = result.itemProvider
        
        prov.loadFileRepresentation(forTypeIdentifier: UTType.image.identifier) { [weak self] url, error in
          
          guard error == nil else {
            debugPrint(error!.localizedDescription, #file, #function)
            return
          }
          
          guard let url = url else {
            debugPrint("itemProvider file representation URL is nil")
            return
          }
          
          // Copy the file the documents folder of the app.
          let fileURL = FileManager.default.getDocumentsDirectory()
          do {
            try FileManager.default.secureCopyItem(at: url, to: fileURL)
          } catch {
            debugPrint("🖼🛠", error.localizedDescription, #fileID, #function)
          }
          
          guard let self = self else { return }
          
          let imageDocumentsUrl = fileURL.appendingPathComponent(url.lastPathComponent)
          debugPrint(imageDocumentsUrl.absoluteString)
          
          // TODO: make async
          let sourceOptions = [kCGImageSourceShouldCache: false] as CFDictionary
          guard let source = CGImageSourceCreateWithURL(url as CFURL, sourceOptions) else {
            return
          }

          let downsampleOptions = [
            kCGImageSourceCreateThumbnailFromImageAlways: true,
            kCGImageSourceCreateThumbnailWithTransform: true,
            kCGImageSourceThumbnailMaxPixelSize: 1536,
          ] as CFDictionary

          guard let cgImage = CGImageSourceCreateThumbnailAtIndex(source, 0, downsampleOptions) else {
            debugPrint("CGImageSourceCreateThumbnailAtIndex failed", #fileID, #function)
            return
          }

          let data = NSMutableData()
          guard let imageDestination = CGImageDestinationCreateWithData(data, UTType.jpeg.identifier as CFString, 1, nil) else {
            assertionFailure()
            return
          }

          let destinationProperties = [
            kCGImageDestinationLossyCompressionQuality: 0.9
          ] as CFDictionary

          CGImageDestinationAddImage(imageDestination, cgImage, destinationProperties)
          CGImageDestinationFinalize(imageDestination)

          let dataSize = ByteCountFormatter.string(fromByteCount: Int64(data.length), countStyle: .memory)
          debugPrint(#fileID, #line, #function, "load image \(dataSize)")
          
          
          let result = StorableImage(
            data: data as Data,
            imageUrl: imageDocumentsUrl
          )
          
          DispatchQueue.main.async {
            self.parent.pickerResult.append(result)
          }
        }
        
        // get the location from the first image because
        // hopefully the selected images are from one location 🤞
        if let assetId = result.assetIdentifier {
          let assetResults = PHAsset.fetchAssets(withLocalIdentifiers: [assetId], options: nil)
          parent.coordinate = assetResults.firstObject?.location?.coordinate
        }
      }
      parent.isPresented = false
    }
  }
  
  public func makeCoordinator() -> Coordinator {
    Coordinator(self)
  }
  
  public func makeUIViewController(context: UIViewControllerRepresentableContext<ImagePicker>) -> PHPickerViewController {
    var config = PHPickerConfiguration(photoLibrary: PHPhotoLibrary.shared())
    config.filter = .images
    config.selectionLimit = 0
    let controller = PHPickerViewController(configuration: config)
    controller.delegate = context.coordinator
    return controller
  }
  
  public func updateUIViewController(
    _ uiViewController: PHPickerViewController,
    context: UIViewControllerRepresentableContext<ImagePicker>
  ) {
    uiViewController.navigationItem.leftBarButtonItem?.tintColor = .purple
  }
}

// MARK: Helper
extension FileManager {
  func getDocumentsDirectory() -> URL {
    let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
    let documentsDirectory = paths[0]
    return documentsDirectory
  }
  
  @discardableResult
  open func secureCopyItem(at srcURL: URL, to dstURL: URL) throws -> Bool {
    do {
      if FileManager.default.fileExists(atPath: dstURL.path) {
        try FileManager.default.removeItem(at: dstURL)
      }
      try FileManager.default.copyItem(at: srcURL, to: dstURL)
    } catch {
      return false
    }
    return true
  }
}

