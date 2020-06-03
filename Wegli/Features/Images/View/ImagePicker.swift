//
//  ImagePicker.swift
//  Wegli
//
//  Created by Stefan Trauth on 28.10.19.
//  Copyright © 2019 Stefan Trauth. All rights reserved.
//

import SwiftUI
import Combine

struct ImagePicker: UIViewControllerRepresentable {

    @Binding var isShown: Bool
    let dataStore: ImageDataStore
    let sourceType: UIImagePickerController.SourceType

    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {

        @Binding var isShown: Bool
        let dataStore: ImageDataStore

        init(isShown: Binding<Bool>, dataStore: ImageDataStore) {
            _isShown = isShown
            self.dataStore = dataStore
        }

        func imagePickerController(_ picker: UIImagePickerController,
                                   didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            let imagePicked = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
            dataStore.add(image: imagePicked)
            isShown = false
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            isShown = false
        }

    }

    func makeCoordinator() -> Coordinator {
        return Coordinator(isShown: $isShown, dataStore: dataStore)
    }

    func makeUIViewController(context: UIViewControllerRepresentableContext<ImagePicker>) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = sourceType
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController,
                                context: UIViewControllerRepresentableContext<ImagePicker>) {

    }

}
