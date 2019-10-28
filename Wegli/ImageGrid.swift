//
//  ImageGrid.swift
//  Wegli
//
//  Created by Stefan Trauth on 15.10.19.
//  Copyright © 2019 Stefan Trauth. All rights reserved.
//

import SwiftUI

struct ImageGrid: View {
    var images: [UIImage]
    var columnCount: Int
    
    var body: some View {
        ForEach(images.chunked(into: columnCount), id: \.self) { images in
            HStack {
                ForEach(images, id: \.self) { image in
                    Image(uiImage: image)
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

struct ImageGrid_Previews: PreviewProvider {
    static var previews: some View {
        ImageGrid(images: [UIImage(systemName: "book")!], columnCount: 3)
    }
}
