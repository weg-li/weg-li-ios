// Created for weg-li in 2021.

import ComposableArchitecture
import CoreLocation
import Foundation
import Helper
import L10n
import PhotoLibraryAccessClient
import SharedModels
import UIKit
import OrderedCollections

public struct ImagesViewState: Equatable, Codable {
  public init(
    alert: AlertState<ImagesViewAction>? = nil,
    showImagePicker: Bool = false,
    storedPhotos: [StorableImage?] = [],
    coordinateFromImagePicker: CLLocationCoordinate2D? = nil,
    dateFromImagePicker: Date? = nil
  ) {
    self.alert = alert
    self.showImagePicker = showImagePicker
    self.storedPhotos = storedPhotos
    self.coordinateFromImagePicker = coordinateFromImagePicker
    self.dateFromImagePicker = dateFromImagePicker
  }
  
  public var alert: AlertState<ImagesViewAction>?
  public var showImagePicker: Bool
  public var storedPhotos: [StorableImage?]
  public var coordinateFromImagePicker: CLLocationCoordinate2D?
  public var dateFromImagePicker: Date?
  
  public var presentTextConfirmationDialog = false
  public var recognizedTextItems: [TextItem] = []
  
  public var licensePlates = OrderedSet<TextItem>()
  
  public var isRecognizingTexts = false
  
  enum CodingKeys: String, CodingKey {
    case showImagePicker
    case storedPhotos
    case coordinateFromImagePicker
    case dateFromImagePicker
  }
  
  public var imageStates: IdentifiedArrayOf<ImageState> {
    IdentifiedArray(
      uniqueElements: storedPhotos
        .compactMap { $0 }
        .map { ImageState(id: $0.id, image: $0) }
    )
  }
  
  public var isValid: Bool {
    !storedPhotos.isEmpty
  }
}

public enum ImagesViewAction: Equatable {
  case setPhotos([StorableImage?])
  case addPhotosButtonTapped
  case setShowImagePicker(Bool)
  case requestPhotoLibraryAccess
  case requestPhotoLibraryAccessResult(PhotoLibraryAuthorizationStatus)
  case setResolvedCoordinate(CLLocationCoordinate2D?)
  case setResolvedDate(Date?)
  case dismissAlert
  case textRecognitionCompleted(Result<[TextItem], VisionError>)
  case selectedText(TextItem)
  case image(id: String, action: ImageAction)
  case setConfimationDialog(Bool)
}

public struct ImagesViewEnvironment {
  public init(
    mainQueue: AnySchedulerOf<DispatchQueue>,
    backgroundQueue: AnySchedulerOf<DispatchQueue>,
    photoLibraryAccessClient: PhotoLibraryAccessClient,
    textRecognitionClient: TextRecognitionClient
  ) {
    self.mainQueue = mainQueue
    self.backgroundQueue = backgroundQueue
    self.photoLibraryAccessClient = photoLibraryAccessClient
    self.textRecognitionClient = textRecognitionClient
  }
  
  public var mainQueue: AnySchedulerOf<DispatchQueue>
  public var backgroundQueue: AnySchedulerOf<DispatchQueue>
  public let photoLibraryAccessClient: PhotoLibraryAccessClient
  public let textRecognitionClient: TextRecognitionClient
  public let distanceFilter: Double = 50
}

/// Reducer handling actions from ImagesView combined with the single Image reducer.
public let imagesReducer = Reducer<ImagesViewState, ImagesViewAction, ImagesViewEnvironment> { state, action, env in
  switch action {
  case .addPhotosButtonTapped:
    switch env.photoLibraryAccessClient.authorizationStatus() {
    case .notDetermined:
      return Effect(value: .requestPhotoLibraryAccess)
    case .restricted, .denied:
      state.alert = .init(title: TextState(L10n.Photos.Alert.accessDenied))
      return .none
    case .authorized, .limited:
      return Effect(value: .setShowImagePicker(true))
    @unknown default:
      return .none
    }
    
  case let .setShowImagePicker(value):
    state.showImagePicker = value
    return .none
    
  case .requestPhotoLibraryAccess:
    return env.photoLibraryAccessClient
      .requestAuthorization()
      .receive(on: env.mainQueue)
      .map(ImagesViewAction.requestPhotoLibraryAccessResult)
      .eraseToEffect()
    
  case let .requestPhotoLibraryAccessResult(status):
    switch status {
    case .authorized, .limited:
      return Effect(value: .setShowImagePicker(true))
    case .notDetermined:
      // show alert
      return .none
    case .denied:
      state.alert = .init(title: TextState(L10n.Photos.Alert.accessDenied))
      return .none
    default:
      return .none
    }
    
  case let .setPhotos(photos):
    state.storedPhotos = photos
    
    guard !photos.isEmpty else {
      state.licensePlates.removeAll()
      state.recognizedTextItems.removeAll()
      return .none
    }
    
    let images = photos.compactMap { $0 }
    
    state.isRecognizingTexts = true
    return .merge(
      images.map { image in
        env.textRecognitionClient
          .recognizeText(in: image, on: env.backgroundQueue)
          .receive(on: env.mainQueue)
          .catchToEffect()
          .delay(for: 0.2, scheduler: env.mainQueue)
          .map(ImagesViewAction.textRecognitionCompleted)
          .eraseToEffect()
      }
    )
    
  case let .textRecognitionCompleted(.success(items)):
    state.isRecognizingTexts = false
    state.recognizedTextItems.append(contentsOf: items)
    
    let licensePlates = items
      .filter { isMatches(germanLicensePlateRegex, $0.text) }
    state.licensePlates.append(contentsOf: licensePlates)
    
    return .none
    
  case let .textRecognitionCompleted(.failure(error)):
    state.isRecognizingTexts = false
    
    debugPrint(error.localizedDescription)
    return .none
    
  case let .selectedText(licensePlate):
    debugPrint(licensePlate)
    return .none
    
    // set photo coordinate from selected photos first element.
  case let .setResolvedCoordinate(coordinate):
    guard let coordinate = coordinate, let resolvedCoordinate = state.coordinateFromImagePicker else {
      return .none
    }
    let resolved = CLLocation(from: resolvedCoordinate)
    let location = CLLocation(from: coordinate)
    
    if resolved.distance(from: location) < env.distanceFilter {
      return .none
    }
    
    state.coordinateFromImagePicker = coordinate
    return .none
    
  case let .setResolvedDate(date):
    state.dateFromImagePicker = date
    return .none
    
  case let .image(id, .removePhoto):
    // filter storedPhotos by image ID which removes the selected one.
    let photos = state.storedPhotos
      .compactMap { $0 }
      .filter { $0.id != id }
    state.storedPhotos = photos
    
    let filterTextItems = state.recognizedTextItems
      .compactMap{ $0 }
      .filter({ $0.id != id })
    state.recognizedTextItems = filterTextItems

    state.licensePlates.removeAll(where: { $0.id == id })
    
    return .none
    
  case let .image(id, .recognizeText):
    let unwrappedPhotos = state.storedPhotos.compactMap { $0 }
    guard
      let image = unwrappedPhotos.first(where: { $0.id == id }) else {
      debugPrint("image can not be found")
      return .none
    }
    return env.textRecognitionClient
      .recognizeText(in: image, on: env.backgroundQueue)
      .receive(on: env.mainQueue)
      .catchToEffect()
      .map(ImagesViewAction.textRecognitionCompleted)
      .eraseToEffect()
    
  case .image:
    return .none
    
  case let .setConfimationDialog(value):
    state.presentTextConfirmationDialog = value
    return .none
    
  case .dismissAlert:
    state.alert = nil
    return .none
  }
}

private func isMatches(_ regex: String, _ string: String) -> Bool {
  do {
    let regex = try NSRegularExpression(pattern: regex)
    
    let matches = regex.matches(in: string, range: NSRange(location: 0, length: string.count))
    return matches.count != 0
  } catch {
    print("Something went wrong! Error: \(error.localizedDescription)")
  }
  
  return false
}

private let germanLicensePlateRegex = "^[a-zA-ZÄÖÜ]{1,3}.[a-zA-Z]{1,2} \\d{1,4}$"
