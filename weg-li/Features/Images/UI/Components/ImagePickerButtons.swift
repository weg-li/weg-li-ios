//
//  ImagePickerButtons.swift
//  weg-li
//
//  Created by Stefan Trauth on 28.10.19.
//  Copyright © 2019 Stefan Trauth. All rights reserved.
//

import SwiftUI

struct ImagePickerButtons: View {
    @State private var showingAlert = false
    @State private var showImagePicker = false
    @State private var imagePickerSourceType = UIImagePickerController.SourceType.photoLibrary
    let imageHandler: (UIImage) -> Void
    
    var body: some View {
        VStack {
            importButton
            cameraButton
        }
        .sheet(
            isPresented: $showImagePicker,
            onDismiss: { showImagePicker = false },
            content: {
                ImagePicker(
                    isShown: $showImagePicker,
                    imageHandler: imageHandler,
                    sourceType: imagePickerSourceType)
            }
        )
    }
    
    private var importButton: some View {
        Button(action: {
            imagePickerSourceType = .photoLibrary
            showImagePicker.toggle()
        }) {
            HStack {
                Image(systemName: "photo.fill.on.rectangle.fill")
                Text("Foto importieren")
            }
            .frame(maxWidth: .infinity)
        }
    }
    
    private var cameraButton: some View {
        Button(action: {
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                self.imagePickerSourceType = .camera
                self.showImagePicker.toggle()
            } else {
                self.showingAlert = true
            }
        }) {
            HStack {
                Image(systemName: "camera.fill")
                Text("Kamera")
            }
            .frame(maxWidth: .infinity)
        }
        .alert(isPresented: $showingAlert) {
            Alert(title: Text("Keine Kamera gefunden!"), message: Text("Bitte ein Gerät mit Kamera benutzen"), dismissButton: .default(Text("OK")))
        }
    }
}

struct ImagePickerButtons_Previews: PreviewProvider {
    static var previews: some View {
        ImagePickerButtons { image in
            print(image)
        }.buttonStyle(EditButtonStyle())
        .preferredColorScheme(.dark)
    }
}
