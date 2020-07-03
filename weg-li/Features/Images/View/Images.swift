//
//  Images.swift
//  weg-li
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
            .buttonStyle(EditButtonStyle())
        }
    }
}

struct Images_Previews: PreviewProvider {
    static var previews: some View {
        Images()
    }
}
