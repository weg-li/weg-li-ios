// Created for weg-li in 2021.

import Combine
import CoreLocation
import ImageConverter
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
        
        // get the location from the first image because
        // hopefully the selected images are from one location 🤞
        if let assetId = result.assetIdentifier {
          let assetResults = PHAsset.fetchAssets(withLocalIdentifiers: [assetId], options: nil)
          parent.coordinate = assetResults.firstObject?.location?.coordinate
        }
        
        prov.loadFileRepresentation(forTypeIdentifier: UTType.image.identifier) { [weak self] url, error in
          guard let self = self else { return }
          
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
            try FileManager.default.copyItem(at: url, to: fileURL)
          } catch {
            debugPrint(error.localizedDescription, #file, #function)
          }
          
          self.converter.downsample(url, on: self.converterQueue.eraseToAnyScheduler())
            .receive(on: DispatchQueue.main)
            .sink { _ in
            } receiveValue: { [weak self] image in
              self?.parent.pickerResult.append(image)
            }
            .store(in: &self.bag)
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
}
