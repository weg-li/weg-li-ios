//
//  ImagePickerButtons.swift
//  weg-li
//
//  Created by Stefan Trauth on 28.10.19.
//  Copyright © 2019 Stefan Trauth. All rights reserved.
//

import SwiftUI

struct ImagePickerButtons: View {
    @State private var showImagePicker: Bool = false
    @State private var imagePickerSourceType = UIImagePickerController.SourceType.photoLibrary
    let imageHandler: (UIImage) -> Void
    
    var body: some View {
        HStack {
            importButton
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                cameraButton
            }
        }
        .sheet(isPresented: $showImagePicker, onDismiss: {
            self.showImagePicker = false
        }, content: {
            ImagePicker(
                isShown: self.$showImagePicker,
                imageHandler: self.imageHandler,
                sourceType: self.imagePickerSourceType)
        })
    }
    
    private var importButton: some View {
        Button(action: {
            self.imagePickerSourceType = .photoLibrary
            self.showImagePicker.toggle()
        }) {
            HStack {
                Image(systemName: "photo.fill.on.rectangle.fill")
                Text("Foto importieren")
            }
        }
    }
    
    private var cameraButton: some View {
        Button(action: {
            self.imagePickerSourceType = .camera
            self.showImagePicker.toggle()
        }) {
            HStack {
                Image(systemName: "camera.fill")
                Text("Kamera")
            }
        }

    }
}

struct ImagePickerButtons_Previews: PreviewProvider {
    static var previews: some View {
        ImagePickerButtons { (image) in
            print(image)
        }.buttonStyle(EditButtonStyle())
    }
}
