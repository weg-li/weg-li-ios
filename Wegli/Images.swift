//
//  Images.swift
//  Wegli
//
//  Created by Stefan Trauth on 09.10.19.
//  Copyright © 2019 Stefan Trauth. All rights reserved.
//

import SwiftUI

struct ImagePickerButtons: View {
    @State private var showImagePicker: Bool = false
    @State private var imagePickerSourceType = UIImagePickerController.SourceType.photoLibrary
    let imageDataStore: ImageDataStore
    
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
        .sheet(isPresented: $showImagePicker, onDismiss: {
            self.showImagePicker = false
        }, content: {
            ImagePicker(isShown: self.$showImagePicker, dataStore: self.imageDataStore, sourceType: self.imagePickerSourceType)
        })
    }
}

struct Images: View {
    @ObservedObject var imageDataStore = ImageDataStore()
    
    var body: some View {
        VStack {
            ImageGrid(images: imageDataStore.images, columnCount: 3)
            ImagePickerButtons(imageDataStore: imageDataStore)
        }
    }
}

struct Images_Previews: PreviewProvider {
    static var previews: some View {
        Images()
    }
}

extension Array {
    func chunked(into size: Int) -> [[Element]] {
        return stride(from: 0, to: count, by: size).map {
            Array(self[$0 ..< Swift.min($0 + size, count)])
        }
    }
}
