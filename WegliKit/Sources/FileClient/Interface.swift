import Combine
import ComposableArchitecture
import Foundation
import Helper
import SharedModels

// MARK: Interface
/// Client handling FileManager interactions
public struct FileClient {
  public var delete: (String) -> Effect<Never, Error>
  public var load: (String) -> Effect<Data, Error>
  public var save: (String, Data) -> Effect<Never, Error>
  
  public func load<A: Decodable>(
    _ type: A.Type,
    from fileName: String,
    with decoder: JSONDecoder = JSONDecoder()
  ) -> Effect<Result<A, NSError>, Never> {
    self.load(fileName)
      .decode(type: A.self, decoder: decoder)
      .mapError { $0 as NSError }
      .catchToEffect()
  }
  
  public func save<A: Encodable>(
    _ data: A, to fileName: String,
    on queue: AnySchedulerOf<DispatchQueue>,
    with encoder: JSONEncoder = JSONEncoder()
  ) -> Effect<Never, Never> {
    Just(data)
      .subscribe(on: queue)
      .encode(encoder: encoder)
      .flatMap { data in self.save(fileName, data) }
      .ignoreFailure()
      .eraseToEffect()
  }
}

// Convenience methods for UserSettings handling
public extension FileClient {
  func loadContactSettings() -> Effect<Result<Contact, NSError>, Never> {
    self.load(Contact.self, from: contactSettingsFileName)
  }

  func saveContactSettings(
    _ contact: Contact, on queue: AnySchedulerOf<DispatchQueue>
  ) -> Effect<Never, Never> {
    self.save(contact, to: contactSettingsFileName, on: queue)
  }
  
  func loadFavoriteCharges() -> Effect<Result<[String], NSError>, Never> {
    self.load([String].self, from: favoriteChargesIdsFileName)
  }
  
  func saveFavoriteCharges(
    _ favorites: [String], on queue: AnySchedulerOf<DispatchQueue>
  ) -> Effect<Never, Never> {
    self.save(favorites, to: favoriteChargesIdsFileName, on: queue)
  }
  
  func loadUserSettings() -> Effect<Result<UserSettings, NSError>, Never> {
    self.load(UserSettings.self, from: userSettingsFilenName)
  }
  
  func saveUserSettings(
    _ settings: UserSettings, on queue: AnySchedulerOf<DispatchQueue>
  ) -> Effect<Never, Never> {
    self.save(settings, to: userSettingsFilenName, on: queue)
  }
}

let contactSettingsFileName = "contact-settings"
let favoriteChargesIdsFileName = "favorite-charge-Ids"
let userSettingsFilenName = "user-settings"
