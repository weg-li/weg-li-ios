// Created for weg-li in 2021.

import Combine
import CoreLocation
import PhotosUI
import SwiftUI

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var isPresented: Bool
    @Binding var pickerResult: [StorableImage?]
    @Binding var coordinate: CLLocationCoordinate2D?

    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        private let parent: ImagePicker

        init(_ parent: ImagePicker) {
            self.parent = parent
        }

        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            guard !results.isEmpty else {
                parent.isPresented = false
                return
            }

            for result in results {
                if result.itemProvider.canLoadObject(ofClass: UIImage.self) {
                    if let assetId = result.assetIdentifier {
                        let assetResults = PHAsset.fetchAssets(withLocalIdentifiers: [assetId], options: nil)
                        parent.coordinate = assetResults.firstObject?.location?.coordinate
                        
                    }
                    result.itemProvider.loadObject(ofClass: UIImage.self) { selectedImage, error in
                        if let error = error {
                            debugPrint(error.localizedDescription)
                        } else if let image = selectedImage as? UIImage {
                            DispatchQueue.main.async {
                                self.parent.pickerResult.append(StorableImage(uiImage: image))
                            }
                        } else {
                            debugPrint("Can not load asset")
                        }
                    }
                }
            }
            parent.isPresented = false
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIViewController(context: UIViewControllerRepresentableContext<ImagePicker>) -> PHPickerViewController {
        var config = PHPickerConfiguration(photoLibrary: PHPhotoLibrary.shared())
        config.filter = .images
        config.selectionLimit = 0
        let controller = PHPickerViewController(configuration: config)
        controller.delegate = context.coordinator
        return controller
    }

    func updateUIViewController(
        _ uiViewController: PHPickerViewController,
        context: UIViewControllerRepresentableContext<ImagePicker>
    ) {
        uiViewController.navigationItem.leftBarButtonItem?.tintColor = .purple
    }
}
