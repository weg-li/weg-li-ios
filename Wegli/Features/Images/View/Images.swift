//
//  Images.swift
//  Wegli
//
//  Created by Stefan Trauth on 09.10.19.
//  Copyright © 2019 Stefan Trauth. All rights reserved.
//

import SwiftUI

struct Images: View {
    @EnvironmentObject private var appStore: AppStore
    
    var body: some View {
        VStack {
            ImageGrid(images: appStore.state.report.images, columnCount: 3)
            ImagePickerButtons { (image) in
                self.appStore.send(.addImage(image))
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
