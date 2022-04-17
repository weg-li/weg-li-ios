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
  @Binding var date: Date?
  
  public class Coordinator: NSObject, PHPickerViewControllerDelegate {
    let parent: ImagePicker
    
    public init(_ parent: ImagePicker) {
      self.parent = parent
    }
    
    public func picker(
      _ picker: PHPickerViewController,
      didFinishPicking results: [PHPickerResult]
    ) {
      for result in results {
        let prov = result.itemProvider
                
        prov.loadFileRepresentation(forTypeIdentifier: UTType.image.identifier) { [weak self] url, error in
          
          guard error == nil else {
            debugPrint(error!.localizedDescription, #fileID, #function)
            return
          }
          
          guard let url = url else {
            debugPrint("itemProvider file representation URL is nil")
            return
          }
          
          let tempFileName = UUID().uuidString
          
          do {
            let data = try Data(contentsOf: url)
            let tempFileUrl = FileManager.default.createDataTempFile(withData: data, withFileName: tempFileName)
            let destinationUrl = try FileManager.default.replaceExistingFile(
              withTempFile: tempFileUrl,
              existingFileName: tempFileName,
              withSubDirectory: "wegli"
            )
            
            DispatchQueue.main.async {
              self?.parent.pickerResult.append(.init(imageUrl: destinationUrl))
            }
          } catch {
            debugPrint(error.localizedDescription)
          }
        }
        
        // get the location from the first image because
        // hopefully the selected images are from one location 🤞
        if let assetId = result.assetIdentifier {
          let assetResults = PHAsset.fetchAssets(withLocalIdentifiers: [assetId], options: nil)
          DispatchQueue.main.async { [weak self] in
            self?.parent.coordinate = assetResults.firstObject?.location?.coordinate
            self?.parent.date = assetResults.firstObject?.creationDate
          }
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
    config.selectionLimit = 3
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
    } catch let error {
      debugPrint("error \(error)")
    }
    guard let destURL = itemReplacementDirectoryURL else { return nil }
    
    let tempFileURL = destURL.appendingPathComponent(name)
    do {
      try data.write(to: tempFileURL, options: .atomic)
      return tempFileURL
    } catch let error {
      debugPrint("error \(error)")
      return nil
    }
  }
  
  func replaceExistingFile(
    withTempFile fileURL: URL?,
    existingFileName: String,
    withSubDirectory: String
  ) throws -> URL? {
    guard let fileURL = fileURL else { return nil }
    let fileManager = FileManager.default
    
    let destPath = try? fileManager.url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
    guard let fullDestPath = destPath?.appendingPathComponent(withSubDirectory + "/" + existingFileName) else { return nil }
    
    let dta = try Data(contentsOf: fileURL)
    createDirectory(withFolderName: "\(withSubDirectory)", toDirectory: .applicationSupportDirectory)
    try dta.write(to: fullDestPath, options: .atomic)
    
    return fullDestPath
  }
  
  func createDirectory(withFolderName dest: String, toDirectory directory: FileManager.SearchPathDirectory = .applicationSupportDirectory) {
      let fileManager = FileManager.default
      let urls = fileManager.urls(for: directory, in: .userDomainMask)
      if let applicationSupportURL = urls.last {
          do{
              var newURL = applicationSupportURL
              newURL = newURL.appendingPathComponent(dest, isDirectory: true)
              try fileManager.createDirectory(at: newURL, withIntermediateDirectories: true, attributes: nil)
          }
          catch{
              debugPrint("error \(error)")
          }
      }
  }
}
