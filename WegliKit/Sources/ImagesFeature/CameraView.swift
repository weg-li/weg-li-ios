import PhotosUI
import SharedModels
import SwiftUI

public struct CameraView: UIViewControllerRepresentable {
  @Binding var isPresented: Bool
  @Binding var pickerResult: [PickerImageResult?]

  public func makeUIViewController(context: UIViewControllerRepresentableContext<CameraView>) -> UIImagePickerController {
    let imagePicker = UIImagePickerController()
    imagePicker.allowsEditing = false
    imagePicker.sourceType = .camera
    imagePicker.delegate = context.coordinator

    return imagePicker
  }

  public func updateUIViewController(_ uiViewController: UIImagePickerController, context: UIViewControllerRepresentableContext<CameraView>) {}

  public func makeCoordinator() -> Coordinator {
    Coordinator(self)
  }

  public final class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    var parent: CameraView

    init(_ parent: CameraView) {
      self.parent = parent
    }

    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
      defer {
        parent.isPresented = false
      }
      guard let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage,
            let imageData = image.jpegData(compressionQuality: 1)
      else {
        debugPrint("originalImage info from ImagePickerController could not be casted to UIImage")
        return
      }

      let filename = "camera\(Date().description)"
      let url = FileManager.default.createDataTempFile(withData: imageData, withFileName: filename)

      var coordinate: CoordinateRegion.Coordinate?
      if let asset: PHAsset = info[UIImagePickerController.InfoKey.phAsset] as? PHAsset,
         let imageCoordinate = asset.location?.coordinate
      {
        coordinate = .init(imageCoordinate)
      }

      parent.pickerResult = [PickerImageResult(
        id: filename,
        imageUrl: url,
        coordinate: coordinate,
        creationDate: Date()
      )]
    }
  }
}
