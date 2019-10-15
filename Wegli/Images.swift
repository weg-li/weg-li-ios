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
    let columnCount = 3
    
    var body: some View {
        ForEach(imageDataStore.images.chunked(into: columnCount), id: \.self) { images in
            HStack {
                ForEach(images, id: \.self) { image in
                    Image(systemName: "book")
                        .resizable()
//                        .scaledToFit()
                        .background(Color.orange)
                        .aspectRatio(1, contentMode: .fill)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                }
                // fill empty cells with clear color to make layout work
                ForEach(0 ..< self.columnCount - images.count) { _ in
                    Color.clear.scaledToFit()
                }
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
