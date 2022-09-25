// Created for weg-li in 2021.

import ComposableArchitecture
import L10n
import SharedModels
import Styleguide
import SwiftUI

public struct ImageView: View {
  @Environment(\.accessibilityReduceMotion) var reduceMotion
  
  @State private var showImageView = false
  @State private var scale: CGFloat = 1
  
  let store: Store<ImageState, ImageAction>
  @ObservedObject private var viewStore: ViewStore<ImageState, ImageAction>
  
  public init(store: Store<ImageState, ImageAction>) {
    self.store = store
    self.viewStore = ViewStore(store)
  }

  public var body: some View {
    if let url = viewStore.image.imageUrl {
      AsyncThumbnailView(url: url)
        .gridModifier
        .padding(.grid(1))
        .contextMenu {
          Button {
            showImageView.toggle()
          } label: {
            Label("Ansehen", systemImage: "eye")
          }
          
          Button {
            viewStore.send(.recognizeText)
          } label: {
            Label("Nummernschild erkennen", systemImage: "text.magnifyingglass")
          }
          
          Button {
            viewStore.send(.removePhoto, animation: .easeOut(duration: 0.2))
          } label: {
            Label("Löschen", systemImage: "trash")
          }
        }
        .popover(isPresented: $showImageView) {
          if let image = viewStore.state.image.asUIImage {
            ZStack(alignment: .topLeading) {
              ZoomableScrollView {
                Image(uiImage: image)
                  .resizable()
                  .aspectRatio(contentMode: .fit)
              }
              .edgesIgnoringSafeArea(.all)
              
              Button(
                action: { showImageView = false },
                label: {
                  Image(systemName: "xmark.circle.fill")
                    .resizable()
                    .frame(width: .grid(8), height: .grid(8))
                }
              )
              .accessibilityLabel(Text(L10n.Button.close))
              .padding()
            }
          } else {
            ProgressView {
              Text("Loading ...")
            }
          }
        }
      
    } else {
      ProgressView {
        Text("Loading ...")
      }
    }
  }
}

private extension View {
  var gridModifier: some View {
    self
      .frame(
        minWidth: 50,
        maxWidth: .infinity,
        minHeight: 100,
        maxHeight: 100
      )
      .clipShape(RoundedRectangle(cornerRadius: 10))
  }
}

struct ImageView_Previews: PreviewProvider {
  static var previews: some View {
    ImageView(
      store: Store<ImageState, ImageAction>(
        initialState: .init(
          id: .init(),
          image: PickerImageResult(uiImage: UIImage(systemName: "pencil")!)! // swiftlint:disable:this force_unwrapping
        ),
        reducer: .empty,
        environment: ImageEnvironment()
      )
    )
  }
}
