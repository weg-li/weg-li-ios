//
//  ImagePickerButtons.swift
//  Wegli
//
//  Created by Stefan Trauth on 28.10.19.
//  Copyright © 2019 Stefan Trauth. All rights reserved.
//

import SwiftUI

struct ImagePickerButtons: View {
    @State private var showImagePicker: Bool = false
    @State private var imagePickerSourceType = UIImagePickerController.SourceType.photoLibrary
    let imageDataStore: ReportImageDataStore
    
    var body: some View {
        HStack {
            Button(action: {
                self.imagePickerSourceType = .photoLibrary
                self.showImagePicker.toggle()
            }) {
                Image(systemName: "photo.fill.on.rectangle.fill")
                Text("Foto importieren")
            }
            .padding()
            .background(Color(.secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 10))
            
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                Button(action: {
                    self.imagePickerSourceType = .camera
                    self.showImagePicker.toggle()
                }) {
                    Image(systemName: "camera.fill")
                    Text("Kamera")
                }
                .padding()
                .background(Color(.secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 10))
            }
        }
        .sheet(isPresented: $showImagePicker, onDismiss: {
            self.showImagePicker = false
        }, content: {
            ImagePicker(isShown: self.$showImagePicker, dataStore: self.imageDataStore, sourceType: self.imagePickerSourceType)
        })
    }
}

struct ImagePickerButtons_Previews: PreviewProvider {
    static var previews: some View {
        ImagePickerButtons(imageDataStore: ReportImageDataStore())
    }
}
