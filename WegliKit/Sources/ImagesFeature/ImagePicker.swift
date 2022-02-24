// Created for weg-li in 2021.

import Combine
import CoreLocation
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
          
          let destinationURL = FileManager.default
            .getDocumentsDirectory()
            .appendingPathComponent(UUID().uuidString)
            .appendingPathExtension(url.pathExtension)
          
          try? FileManager.default.secureCopyItem(at: url, to: destinationURL)
          
          DispatchQueue.main.async {
            self?.parent.pickerResult.append(.init(imageUrl: destinationURL))            
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

