// Created for weg-li in 2021.

import Combine
import CoreLocation
import os.log
import PhotosUI
import SharedModels
import SwiftUI
import UniformTypeIdentifiers

public struct ImagePicker: UIViewControllerRepresentable {
  public init(isPresented: Binding<Bool>, pickerResult: Binding<[PickerImageResult?]>) {
    self._isPresented = isPresented
    self._pickerResult = pickerResult
  }
  
  @Binding var isPresented: Bool
  @Binding var pickerResult: [PickerImageResult?]
  
  public class Coordinator: NSObject, PHPickerViewControllerDelegate {
    let parent: ImagePicker
    
    public init(_ parent: ImagePicker) {
      self.parent = parent
    }
    
    public func picker(
      _ picker: PHPickerViewController,
      didFinishPicking results: [PHPickerResult]
    ) {
      let dispatchQueue = DispatchQueue(label: "li.weg.iOS.ImagePickerQueue")
      var selectedImageDatas = [Data?](repeating: nil, count: results.count) // Awkwardly named, sure
      var totalConversionsCompleted = 0
      
      for (index, result) in results.enumerated() {
        result.itemProvider.loadFileRepresentation(forTypeIdentifier: UTType.image.identifier) { (url, error) in
          guard let url = url else {
            dispatchQueue.sync { totalConversionsCompleted += 1 }
            return
          }
          
          let sourceOptions = [kCGImageSourceShouldCache: false] as CFDictionary
          
          guard let source = CGImageSourceCreateWithURL(url as CFURL, sourceOptions) else {
            dispatchQueue.sync { totalConversionsCompleted += 1 }
            return
          }
          
          let downsampleOptions = [
            kCGImageSourceCreateThumbnailFromImageAlways: true,
            kCGImageSourceCreateThumbnailWithTransform: true,
            kCGImageSourceThumbnailMaxPixelSize: 2_000,
          ] as CFDictionary
          
          guard let cgImage = CGImageSourceCreateThumbnailAtIndex(source, 0, downsampleOptions) else {
            dispatchQueue.sync { totalConversionsCompleted += 1 }
            return
          }
          
          let data = NSMutableData()
          
          guard 
            let imageDestination = CGImageDestinationCreateWithData(
              data, UTType.jpeg.identifier as CFString, 1, nil
            )
          else {
            dispatchQueue.sync { totalConversionsCompleted += 1 }
            return
          }
          
          // Don't compress PNGs, they're too pretty
          let isPNG: Bool = {
            guard let utType = cgImage.utType else { return false }
            return (utType as String) == UTType.png.identifier
          }()
          
          let destinationProperties = [
            kCGImageDestinationLossyCompressionQuality: isPNG ? 1.0 : 0.9
          ] as CFDictionary
          
          CGImageDestinationAddImage(imageDestination, cgImage, destinationProperties)
          CGImageDestinationFinalize(imageDestination)
          
          dispatchQueue.sync {
            selectedImageDatas[index] = data as Data
            totalConversionsCompleted += 1
          }
          
          DispatchQueue.main.async {
            var assetCoordinate: CoordinateRegion.Coordinate?
            var creationDate: Date?
            if let assetId = result.assetIdentifier {
              let assetResults = PHAsset.fetchAssets(
                withLocalIdentifiers: [assetId],
                options: nil
              )
              if let coordinate = assetResults.firstObject?.location?.coordinate {
                assetCoordinate = .init(
                  latitude: coordinate.latitude,
                  longitude: coordinate.longitude
                )
              }
              creationDate = assetResults.firstObject?.creationDate
            }
            self.parent.pickerResult.append(
              PickerImageResult(
                id: "IMG_\(index)_\(Date().formatted(date: .numeric, time: .omitted)).jpg",
                uiImage: selectedImageDatas[index],
                coordinate: assetCoordinate,
                creationDate: creationDate
              )
            )
          }
        }
      }
      
      DispatchQueue.main.async { [weak self] in
        self?.parent.isPresented = false
        self?.parent.pickerResult.removeAll()
      }
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
  
  func createDataTempFile(withData data: Data?, withFileName name: String) -> URL? {
    let fileManager = FileManager.default
    guard
      let destinationURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first,
      let data = data
    else {
      return nil
    }
    
    var itemReplacementDirectoryURL: URL?
    do {
      try itemReplacementDirectoryURL = fileManager.url(
        for: .itemReplacementDirectory,
        in: .userDomainMask,
        appropriateFor: destinationURL,
        create: true
      )
    } catch {
      debugPrint("error \(error)")
    }
    guard let destURL = itemReplacementDirectoryURL else { return nil }
    
    let tempFileURL = destURL.appendingPathComponent(name)
    do {
      try data.write(to: tempFileURL, options: .atomic)
      return tempFileURL
    } catch {
      debugPrint("error \(error)")
      return nil
    }
  }
  
  func replaceExistingFile(
    withTempFile fileURL: URL?,
    existingFileName: String,
    subDirectory: String
  ) throws -> URL? {
    guard let fileURL = fileURL else { return nil }
    let fileManager = FileManager.default
    
    let destPath = try? fileManager.url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
    guard let fullDestPath = destPath?.appendingPathComponent(subDirectory + "/" + existingFileName) else { return nil }
    
    let dta = try Data(contentsOf: fileURL)
    createDirectory(withFolderName: "\(subDirectory)", toDirectory: .applicationSupportDirectory)
    try dta.write(to: fullDestPath, options: .atomic)
    return fullDestPath
  }
  
  func createDirectory(withFolderName dest: String, toDirectory directory: FileManager.SearchPathDirectory = .applicationSupportDirectory) {
    let fileManager = FileManager.default
    let urls = fileManager.urls(for: directory, in: .userDomainMask)
    if let applicationSupportURL = urls.last {
      do {
        var newURL = applicationSupportURL
        newURL = newURL.appendingPathComponent(dest, isDirectory: true)
        try fileManager.createDirectory(at: newURL, withIntermediateDirectories: true, attributes: nil)
      } catch {
        debugPrint("error \(error)")
      }
    }
  }
}
