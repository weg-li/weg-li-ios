import SwiftUI
import SharedModels

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

  final public class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    var parent: CameraView

    init(_ parent: CameraView) {
      self.parent = parent
    }

    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
      defer {
        parent.isPresented = false
      }
      guard let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage,
      let imageData = image.jpegData(compressionQuality: 1) else {
        return
      }

      let filename = "camera\(Date().description)"
      let url = FileManager.default.createDataTempFile(withData: imageData, withFileName: filename)

      parent.pickerResult = [PickerImageResult(
        id: filename,
        imageUrl: url,
        coordinate: nil,
        creationDate: Date()
      )]
    }
  }
}
