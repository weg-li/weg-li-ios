// Created for weg-li in 2021.

import Combine
import CoreLocation
import PhotosUI
import SwiftUI

typealias ImagePickerHander = (UIImage, CLLocationCoordinate2D?) -> Void

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var isPresented: Bool
    let imagePickerHandler: ImagePickerHander

    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        private let parent: ImagePicker

        init(_ parent: ImagePicker) {
            self.parent = parent
        }

        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            guard !results.isEmpty else {
                return
            }

            let imageResult = results[0]

            var coordinate: CLLocationCoordinate2D?
            if imageResult.itemProvider.canLoadObject(ofClass: UIImage.self) {
                var image: UIImage?
                if let assetId = imageResult.assetIdentifier {
                    let assetResults = PHAsset.fetchAssets(withLocalIdentifiers: [assetId], options: nil)
                    coordinate = assetResults.firstObject?.location?.coordinate
                }

                imageResult.itemProvider.loadObject(ofClass: UIImage.self) { selectedImage, error in
                    if let error = error {
                        print(error.localizedDescription)
                    } else {
                        image = selectedImage as? UIImage
                        DispatchQueue.main.async {
                            self.parent.imagePickerHandler(
                                image!,
                                coordinate)
                        }
                    }
                }
            }

            parent.isPresented = false
        }

        func imagePickerControllerDidCancel(_ picker: PHPickerViewController) {
            parent.isPresented = false
        }
    }

    func makeCoordinator() -> Coordinator {
        return Coordinator(self)
    }

    func makeUIViewController(context: UIViewControllerRepresentableContext<ImagePicker>) -> PHPickerViewController {
        var config = PHPickerConfiguration(photoLibrary: PHPhotoLibrary.shared())
        config.filter = .images
        config.selectionLimit = 1
        let controller = PHPickerViewController(configuration: config)
        controller.delegate = context.coordinator
        return controller
    }

    func updateUIViewController(
        _ uiViewController: PHPickerViewController,
        context: UIViewControllerRepresentableContext<ImagePicker>) {}
}
