// Created for weg-li in 2021.

import SwiftUI

struct ImageGrid: View {
    let images: [UIImage]
    var columnCount: Int = 3
    let imageHandler: (Int) -> Void

    var body: some View {
        ForEach(images.chunked(into: columnCount), id: \.self) { images in
            HStack {
                ForEach(images.indices) { index in
                    VStack {
                        Button(action: {
                            self.imageHandler(index)
                        }) {
                                HStack {
                                    Image(systemName: "trash")
                                    Text("Löschen")
                                }
                        }
                        Image(uiImage: images[index])
                            .gridModifier
                            .frame(maxHeight: 200)
                    }
                }
            }
        }
    }
}

private extension Image {
    var gridModifier: some View {
        self
            .resizable()
            .background(Color.orange)
            .aspectRatio(1, contentMode: .fill)
            .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}

struct ImageGrid_Previews: PreviewProvider {
    static var previews: some View {
        ImageGrid(images: [
            UIImage(systemName: "book")!,
            UIImage(systemName: "book")!,
            UIImage(systemName: "book")!
        ], columnCount: 3) { index in
                print(index)
        }
    }
}
