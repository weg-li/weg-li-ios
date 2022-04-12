// Created for weg-li in 2021.

import ComposableArchitecture
import CoreLocation
import L10n
import SharedModels
import Styleguide
import SwiftUI

public struct ImagesView: View {
  let store: Store<ImagesViewState, ImagesViewAction>
  @ObservedObject private var viewStore: ViewStore<ImagesViewState, ImagesViewAction>
  
  public init(store: Store<ImagesViewState, ImagesViewAction>) {
    self.store = store
    viewStore = ViewStore(store)
  }
  
  let rows = [GridItem(.fixed(25))]
  
  public var body: some View {
    VStack(alignment: .center, spacing: 20.0) {
      ImageGrid(store: store)
      
      importButton
        .buttonStyle(EditButtonStyle())
        .padding(.bottom, 4)
      
      Divider()
      
      VStack(alignment: .center) {
        Label("Erkannte Nummernschilder", systemImage: "text.magnifyingglass")
          .font(.subheadline)
          .foregroundColor(Color(.label))
          .padding(.bottom, 4)
        if viewStore.state.licensePlates.isEmpty {
          Text("Keine")
            .italic()
            .font(.callout)
            .foregroundColor(Color(.secondaryLabel))
        } else {
          VStack {
            ScrollView(.horizontal) {
              Spacer(minLength: 4)
              LazyHGrid(rows: rows, alignment: .center) {
                ForEach(viewStore.state.licensePlates, id: \.self) { item in
                  Button(
                    action: { viewStore.send(.selectedText(item)) },
                    label: {
                      Text(item)
                        .font(.custom("Menlo", size: 18, relativeTo: .headline))
                        .foregroundColor(Color(.label))
                        .textCase(.uppercase)
                    }
                  )
                  .font(.body)
                  .foregroundColor(.white)
                  .padding(8)
                  .background(.background)
                  .clipShape(
                    RoundedRectangle(cornerRadius: 8, style: .circular)
                  )
                  .overlay(
                    RoundedRectangle(cornerRadius: 8)
                      .stroke(Color(.label), lineWidth: 2)
                  )
                  .padding(.horizontal, 2)
                }
              }
              .frame(height: 50)
            }
            Text("Selektieren um es in der Beschreibung zu verwenden")
              .multilineTextAlignment(.leading)
              .foregroundColor(Color(.secondaryLabel))
              .font(.footnote)
          }
          .animation(.easeOut, value: viewStore.recognizedTexts.isEmpty)
          .transition(.opacity)
        }
      }
    }
    .alert(store.scope(state: { $0.alert }), dismiss: .dismissAlert)
    .sheet(
      isPresented: viewStore.binding(
        get: \.showImagePicker,
        send: ImagesViewAction.setShowImagePicker
      ),
      content: {
        ImagePicker(
          isPresented: viewStore.binding(
            get: \.showImagePicker,
            send: ImagesViewAction.setShowImagePicker
          ),
          pickerResult: viewStore.binding(
            get: \.storedPhotos,
            send: ImagesViewAction.setPhotos
          ),
          coordinate: viewStore.binding(
            get: \.coordinateFromImagePicker,
            send: ImagesViewAction.setResolvedCoordinate
          ),
          date: viewStore.binding(
            get: \.dateFromImagePicker,
            send: ImagesViewAction.setResolvedDate
          )
        )
      }
    )
  }
  
  private var importButton: some View {
    Button(action: {
      viewStore.send(.addPhotosButtonTapped)
    }) {
      HStack {
        Image(systemName: "photo.fill.on.rectangle.fill")
        Text(L10n.Photos.ImportButton.copy)
      }
      .frame(maxWidth: .infinity)
    }
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
