//
//  Images.swift
//  Wegli
//
//  Created by Stefan Trauth on 09.10.19.
//  Copyright © 2019 Stefan Trauth. All rights reserved.
//

import SwiftUI

struct Images: View {
    @ObservedObject var imageDataStore = ImageDataStore()
    
    var body: some View {
        VStack {
            ImageGrid(images: imageDataStore.images, columnCount: 3)
            HStack {
                Button(action: {
                    
                }) {
                    Image(systemName: "photo.fill.on.rectangle.fill")
                    Text("Foto importieren")
                }
                .padding()
                .background(Color(.secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 10))
                Button(action: {
                    
                }) {
                    Image(systemName: "camera.fill")
                    Text("Kamera")
                }
                .padding()
                .background(Color(.secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 10))
            }
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
