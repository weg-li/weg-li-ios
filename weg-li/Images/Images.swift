// Created for weg-li in 2021.

import SwiftUI

struct Images: View {
    @ObservedObject var imageDataStore = ImageDataStore()

    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

struct Images_Previews: PreviewProvider {
    static var previews: some View {
        Images()
    }
}
