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
  
  let rows = [GridItem(.flexible(minimum: 30, maximum: 60))]
  
  public var body: some View {
    VStack(alignment: .center, spacing: 20.0) {
      ImageGrid(store: store)
      
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
          if viewStore.isRecognizingTexts {
            ActivityIndicator(style: .medium)
          }
        }
        if viewStore.state.licensePlates.isEmpty {
          Text("Keine")
            .italic()
            .font(.callout)
            .foregroundColor(Color(.secondaryLabel))
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
  
  @ViewBuilder private func licensePlateView(item: TextItem) -> some View {
    Button(
      action: { viewStore.send(.selectedTextItem(item)) },
      label: {
        Text(item.text)
          .font(.custom(FontName.nummernschild.rawValue, size: 24, relativeTo: .headline))
          .foregroundColor(Color(.label))
          .textCase(.uppercase)
      }
    )
      .font(.body)
      .foregroundColor(Color(.label))
      .padding(.grid(2))
      .background(.background)
      .clipShape(
        RoundedRectangle(cornerRadius: 8, style: .circular)
      )
      .overlay(
        RoundedRectangle(cornerRadius: 8)
          .stroke(Color(.label), lineWidth: 2)
      )
      .padding(.horizontal, 2)
      .accessibility(value: Text(item.text))
  }
  
  private var importButton: some View {
    Button(action: {
      viewStore.send(.addPhotosButtonTapped)
    }) {
      Label(L10n.Photos.ImportButton.copy, systemImage: "photo.fill.on.rectangle.fill")
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
