// Created for weg-li in 2021.

import ComposableArchitecture
import CoreLocation
import L10n
import SharedModels
import Styleguide
import SwiftUI

public struct ImagesView: View {
  let store: Store<ImagesViewDomain.State, ImagesViewDomain.Action>
  @ObservedObject private var viewStore: ViewStore<ImagesViewDomain.State, ImagesViewDomain.Action>
  
  public init(store: Store<ImagesViewDomain.State, ImagesViewDomain.Action>) {
    self.store = store
    self.viewStore = ViewStore(store)
  }
  
  let rows = [GridItem(.flexible(minimum: 30, maximum: 60))]
  
  public var body: some View {
    VStack(alignment: .center, spacing: 20.0) {
      ImageGrid(store: store)
      
      takePhotoButton
        .buttonStyle(EditButtonStyle())

      importButton
        .buttonStyle(EditButtonStyle())
        .padding(.bottom, .grid(1))

      Divider()

      VStack(alignment: .center) {
        HStack {
          Label("Erkannte Nummernschilder", systemImage: "text.magnifyingglass")
            .font(.subheadline)
            .foregroundColor(Color(.label))
            .padding(.bottom, .grid(1))
        }
        if viewStore.state.licensePlates.isEmpty {
          Text("Keine")
            .italic()
            .font(.callout)
            .foregroundColor(Color(.secondaryLabel))
        } else if viewStore.isRecognizingTexts {
          ActivityIndicator(style: .medium, color: .gray)
        } else {
          VStack {
            ScrollView(.horizontal) {
              Spacer(minLength: .grid(1))
              LazyHGrid(rows: rows, alignment: .center) {
                ForEach(viewStore.state.licensePlates, id: \.self) { item in
                  licensePlateView(item: item)
                    .accessibilityElement()
                }
              }
              .accessibilityElement()
              .frame(minHeight: 50)
            }
            Text("Selektieren um es in der Beschreibung zu verwenden")
              .multilineTextAlignment(.leading)
              .foregroundColor(Color(.secondaryLabel))
              .font(.footnote)
          }
          .animation(.easeOut, value: viewStore.recognizedTextItems.isEmpty)
          .transition(.opacity)
        }
      }
      .accessibilityElement(children: .combine)
    }
    .alert(store.scope(state: \.alert), dismiss: .dismissAlert)
    .sheet(
      isPresented: viewStore.binding(
        get: \.showImagePicker,
        send: ImagesViewDomain.Action.setShowImagePicker
      ),
      content: {
        ImagePicker(
          isPresented: viewStore.binding(
            get: \.showImagePicker,
            send: ImagesViewDomain.Action.setShowImagePicker
          ),
          pickerResult: viewStore.binding(
            get: \.storedPhotos,
            send: ImagesViewDomain.Action.setPhotos
          )
        )
      }
    )
    .fullScreenCover(
      isPresented: viewStore.binding(
        get: \.showCamera,
        send: ImagesViewDomain.Action.setShowCamera
      ),
      content: {
        CameraView(
          isPresented: viewStore.binding(
            get: \.showCamera,
            send: ImagesViewDomain.Action.setShowCamera
          ),
          pickerResult: viewStore.binding(
            get: \.storedPhotos,
            send: ImagesViewDomain.Action.setPhotos
          )
        )
        .edgesIgnoringSafeArea(.vertical)
      }
    )
  }
  
  @ViewBuilder private func licensePlateView(item: TextItem) -> some View {
    Button(
      action: { viewStore.send(.selectedTextItem(item)) },
      label: {
        HStack {
          Color.blue
            .frame(width: 10)
          Text(item.text)
            .font(.custom(FontName.nummernschild.rawValue, size: 24, relativeTo: .headline))
            .foregroundColor(.black)
            .textCase(.uppercase)
            .padding(.vertical, .grid(1))
        }
        .fixedSize(horizontal: false, vertical: true)
        .padding(.trailing, .grid(1))
      }
    )
    .background(Color.white)
    .clipShape(
      RoundedRectangle(cornerRadius: 8, style: .circular)
    )
    .overlay(
      RoundedRectangle(cornerRadius: 8)
        .stroke(Color.black, lineWidth: 2)
    )
    .padding(.horizontal, 4)
    .accessibility(value: Text(item.text))
  }
  
  private var importButton: some View {
    Button(
      action: { viewStore.send(.onAddPhotosButtonTapped) },
      label: {
        Label(L10n.Photos.ImportButton.copy, systemImage: "photo.on.rectangle.angled")
          .frame(maxWidth: .infinity)
      }
    )
  }

  private var takePhotoButton: some View {
    Button(
      action: { viewStore.send(.onTakePhotosButtonTapped) },
      label: {
        Label(L10n.Camera.TakePhotoButton.copy, systemImage: "camera")
          .frame(maxWidth: .infinity)
      }
    )
  }
}

struct Images_Previews: PreviewProvider {
  static var previews: some View {
    ImagesView(
      store: .init(
        initialState: .init(),
        reducer: .empty,
        environment: ()
      )
    )
  }
}
