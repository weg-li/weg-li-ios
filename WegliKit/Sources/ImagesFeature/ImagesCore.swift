// Created for weg-li in 2021.

import CameraAccessClient
import ComposableArchitecture
import CoreLocation
import Foundation
import Helper
import L10n
import OrderedCollections
import PhotoLibraryAccessClient
import SharedModels
import UIKit

public struct ImagesViewDomain: Reducer {
  public init() {}
  
  @Dependency(\.continuousClock) public var clock
  @Dependency(\.cameraAccessClient) public var cameraAccessClient
  @Dependency(\.photoLibraryAccessClient) public var photoLibraryAccessClient
  @Dependency(\.textRecognitionClient) public var textRecognitionClient
  public let distanceFilter: Double = 50
  
  public struct State: Equatable {
    public init(
      alert: AlertState<Action>? = nil,
      showCamera: Bool = false,
      showImagePicker: Bool = false,
      storedPhotos: [PickerImageResult?] = [],
      coordinateFromImagePicker: CLLocationCoordinate2D? = nil,
      dateFromImagePicker: Date? = nil
    ) {
      self.alert = alert
      self.showImagePicker = showImagePicker
      self.showCamera = showCamera
      self.storedPhotos = storedPhotos
      self.pickerResultCoordinate = coordinateFromImagePicker
      self.pickerResultDate = dateFromImagePicker
    }
    
    public var alert: AlertState<Action>?
    @BindingState public var showImagePicker: Bool
    @BindingState public var showCamera: Bool
    public var storedPhotos: [PickerImageResult?]
    public var pickerResultCoordinate: CLLocationCoordinate2D?
    public var pickerResultDate: Date?
    
    public var showsAllTextRecognitionResults = false
    public var recognizedTextItems: [TextItem] = []
    public var licensePlates = OrderedSet<TextItem>()
    public var isRecognizingTexts = false
    
    public var imageStates: IdentifiedArrayOf<ImageDomain.State> {
      let imagesSet = OrderedSet(storedPhotos)
      return IdentifiedArray(
        uniqueElements: imagesSet.elements
          .compactMap { $0 }
          .map { ImageDomain.State(id: $0.id, image: $0) }
      )
    }
    
    public var isValid: Bool {
      !storedPhotos.isEmpty
    }
  }
  
  public enum Action: Equatable, BindableAction {
    case binding(BindingAction<State>)
    case onAddPhotosButtonTapped
    case onTakePhotosButtonTapped
    case setPhotos([PickerImageResult?])
    case justSetPhotos([PickerImageResult])
    case setShowImagePicker(Bool)
    case setShowCamera(Bool)
    case requestPhotoLibraryAccess
    case requestPhotoLibraryAccessResult(PhotoLibraryAuthorizationStatus)
    case requestCameraAccess
    case requestCameraAccessResult(TaskResult<Bool>)
    case setImageCoordinate(CLLocationCoordinate2D?)
    case setImageCreationDate(Date?)
    case dismissAlert
    case textRecognitionCompleted(TaskResult<[TextItem]>)
    case selectedTextItem(TextItem)
    case image(id: String, action: ImageDomain.Action)
  }
  
  public var body: some ReducerOf<Self> {
    BindingReducer()
    
    Reduce<State, Action> { state, action in
      switch action {
      case .binding:
        return .none
        
      case .onAddPhotosButtonTapped:
        switch photoLibraryAccessClient.authorizationStatus() {
        case .notDetermined:
          return .send(.requestPhotoLibraryAccess)
        case .restricted, .denied:
          state.alert = .init(title: TextState(L10n.Photos.Alert.accessDenied))
          return .none
        case .authorized, .limited:
          return .send(.setShowImagePicker(true))
        @unknown default:
          return .none
        }
        
      case let .setShowImagePicker(value):
        state.showImagePicker = value
        return .none
        
      case .requestPhotoLibraryAccess:
        return .run { send in
          await send(
            .requestPhotoLibraryAccessResult(
              await photoLibraryAccessClient.requestAuthorization()
            )
          )
        }
            
      case let .requestPhotoLibraryAccessResult(status):
        switch status {
        case .authorized, .limited:
          return .send(.setShowImagePicker(true))
        case .notDetermined:
          // show alert
          return .none
        case .denied:
          state.alert = .init(title: TextState(L10n.Photos.Alert.accessDenied))
          return .none
        default:
          return .none
        }

      case .onTakePhotosButtonTapped:
        switch cameraAccessClient.authorizationStatus() {
        case .authorized:
          return .send(.setShowCamera(true))
        case .denied:
          state.alert = .init(title: TextState(L10n.Camera.Alert.accessDenied))
          return .none
        case .notDetermined:
          return .send(.requestCameraAccess)
        case .restricted:
          return .none
        @unknown default:
          return .none
        }

      case let .setShowCamera(value):
        state.showCamera = value
        return .none

      case .requestCameraAccess:
        return .run { send in
          await send(
            .requestCameraAccessResult(
              TaskResult {
                await cameraAccessClient.requestAuthorization()
              }
            )
          )
        }

      case let .requestCameraAccessResult(result):
        let userDidGrantAccess = (try? result.value) ?? false
        if userDidGrantAccess {
          return .send(.setShowCamera(true))
        }
        return .none

      case let .setPhotos(photos):
        state.storedPhotos.append(contentsOf: photos)
      
        guard !photos.isEmpty else {
          state.licensePlates.removeAll()
          state.recognizedTextItems.removeAll()
          return .none
        }
        
        let images = photos.compactMap { $0 }
        state.isRecognizingTexts = true
        
        return .merge(
          .send(.setImageCoordinate(images.imageCoordinates.first)),
          .send(.setImageCreationDate(images.imageCreationDates.first)),
          .textRecognition(in: images, client: textRecognitionClient)
        )
        
      case let .textRecognitionCompleted(.success(items)):
        state.isRecognizingTexts = false
                
        if state.showsAllTextRecognitionResults {
          state.licensePlates.append(contentsOf: items)
        } else {
          var licensePlates = items
          for index in licensePlates.indices {
            let cleanText = licensePlates[index].text
              .filter { !$0.isLowercase }
              .withReplacedCharacters("-.,:; ", by: " ")
            licensePlates[index].text = cleanText
          }
          
          let filteredLicensePlates = licensePlates.filter { textItem in
            isMatches(germanLicensePlateRegex, textItem.text)
          }
          state.licensePlates.append(contentsOf: filteredLicensePlates)
        }
        
        return .none
        
      case let .textRecognitionCompleted(.failure(error)):
        state.isRecognizingTexts = false
        
        debugPrint(error.localizedDescription)
        return .none
        
      case let .selectedTextItem(licensePlate):
        debugPrint(licensePlate)
        return .none
        
      // set photo coordinate from selected photos first element.
      case let .setImageCoordinate(coordinate):
        guard let coordinate = coordinate, let resolvedCoordinate = state.pickerResultCoordinate else {
          return .none
        }
        let resolved = CLLocation(from: resolvedCoordinate)
        let location = CLLocation(from: coordinate)
        
        if resolved.distance(from: location) < distanceFilter {
          return .none
        }
        
        state.pickerResultCoordinate = coordinate
        return .none
        
      case let .setImageCreationDate(date):
        state.pickerResultDate = date
        return .none
        
      case let .justSetPhotos(photos):
        state.storedPhotos = photos
        return .none
        
      case let .image(id, .onRemovePhotoButtonTapped):
        // filter storedPhotos by image ID which removes the selected one.
        let photos = state.storedPhotos
          .compactMap { $0 }
          .filter { $0.id != id }
        
        var effects: [Effect<Action>] = []
        
        if !photos.isEmpty {
          state.storedPhotos = photos
        } else {
          effects.append(
            Effect.run(operation: { send in
              try await clock.sleep(for: .milliseconds(800))
              await send(.justSetPhotos(photos), animation: .easeOut)
            })
          )
        }
        
        let filterTextItems = state.recognizedTextItems
          .compactMap { $0 }
          .filter { $0.id != id }
        state.recognizedTextItems = filterTextItems

        state.licensePlates.removeAll(where: { $0.id == id })
        
        
        
        let imageCoordinates = state.storedPhotos.compactMap { $0 }.imageCoordinates
        if !imageCoordinates.isEmpty, let firstCoordinate = imageCoordinates.first {
          effects.append(
            .send(.setImageCoordinate(firstCoordinate))
          )
        }
        let imageCreationDates = state.storedPhotos.compactMap { $0 }.imageCreationDates
        if !imageCreationDates.isEmpty, let firstDate = imageCreationDates.first {
          effects.append(
            .send(.setImageCreationDate(firstDate))
          )
        }
        return .merge(effects)
        
      case let .image(id, .onRecognizeTextButtonTapped):
        let unwrappedPhotos = state.storedPhotos.compactMap { $0 }
        guard
          let image = unwrappedPhotos.first(where: { $0.id == id })
        else {
          debugPrint("image can not be found")
          return .none
        }
        
        state.isRecognizingTexts = true
        
        return .run { send in
          await send(
            Action.textRecognitionCompleted(
              TaskResult {
                try await clock.sleep(for: .milliseconds(200))
                return try await textRecognitionClient.recognizeText(image)
              }
            )
          )
        }
        
      case .image:
        return .none
        
      case .dismissAlert:
        state.alert = nil
        return .none
      }
    }
  }
}

// MARK: Helper


private extension Effect {
  static func textRecognition(
    in images: [PickerImageResult],
    client: TextRecognitionClient
  ) -> Effect<ImagesViewDomain.Action> {
    .run { send in
      await send(withThrowingTaskGroup(of: [TextItem].self) { group in
        for image in images {
          group.addTask {
            try await client.recognizeText(image)
          }
        }
        
        do {
          var results: [[TextItem]] = []
          
          for try await result in group {
            results.append(result)
          }
          
          let flattenedResults = results.flatMap { $0 }
          return ImagesViewDomain.Action.textRecognitionCompleted(.success(flattenedResults))
        } catch {
          return ImagesViewDomain.Action.textRecognitionCompleted(.failure(error))
        }
      })
    }
  }
}

private func isMatches(_ regex: String, _ string: String) -> Bool {
  do {
    let regex = try NSRegularExpression(pattern: regex)
    
    let matches = regex.matches(in: string, range: NSRange(location: 0, length: string.count))
    return matches.count != 0
  } catch {
    debugPrint("Something went wrong! Error: \(error.localizedDescription)")
  }
  
  return false
}

private let germanLicensePlateRegex = "^[a-zA-ZÄÖÜ]{1,3}.[a-zA-Z]{1,2} \\d{1,4}[A-Z]{0,1}$" // TODO: Do swift regex

extension String {
  func withReplacedCharacters(_ characters: String, by separator: String) -> String {
    let characterSet = CharacterSet(charactersIn: characters)
    let components = components(separatedBy: characterSet)
      .filter { !$0.isEmpty }
    return components.joined(separator: separator)
  }
}

extension Array where Element == PickerImageResult {
  var imageCoordinates: [CLLocationCoordinate2D] {
    compactMap { $0.coordinate?.asCLLocationCoordinate2D }
  }
  
  var imageCreationDates: [Date] {
    compactMap(\.creationDate)
  }
}
