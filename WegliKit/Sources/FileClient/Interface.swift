import Foundation
import Helper
import SharedModels

// MARK: Interface

/// Client handling FileManager interactions
public struct FileClient {
  public var removeItem: @Sendable (URL) async throws -> Void
  public var delete: @Sendable (String) async throws -> Void
  public var load: @Sendable (String) async throws -> Data
  public var save: @Sendable (String, Data) async throws -> Void
  
  public func load<A: Decodable>(
    _ type: A.Type,
    from fileName: String,
    with decoder: JSONDecoder = JSONDecoder()
  ) async throws -> A {
    let data = try await load(fileName)
    return try data.decoded(decoder: decoder)
  }
  
  public func save<A: Encodable>(
    _ data: A,
    to fileName: String,
    with encoder: JSONEncoder = JSONEncoder()
  ) async -> Swift.Void {
    Task(priority: .background) {
      let data = try data.encoded(encoder: encoder)
      try await self.save(fileName, data)
    }
  }
}

// Convenience methods for UserSettings handling
public extension FileClient {
  func loadContactSettings() async throws -> Contact {
    try await load(Contact.self, from: contactSettingsFileName)
  }

  func saveContactSettings(_ contact: Contact) async -> Void {
    await save(contact, to: contactSettingsFileName)
  }
  
  func loadFavoriteCharges() async throws -> [String] {
    try await load([String].self, from: favoriteChargesIdsFileName)
  }
  
  func saveFavoriteCharges(_ favorites: [String]) async throws -> Void {
    await save(favorites, to: favoriteChargesIdsFileName)
  }
  
  func loadUserSettings() async throws -> UserSettings {
    try await load(UserSettings.self, from: userSettingsFilenName)
  }
  
  func saveUserSettings(_ settings: UserSettings) async -> Void {
    await save(settings, to: userSettingsFilenName)
  }
  
  func loadNotices(decoder: JSONDecoder = .noticeDecoder) async throws -> [Notice] {
    try await load([Notice].self, from: noticesFileName, with: decoder)
  }
  
  func saveNotices(_ notices: [Notice]?, encoder: JSONEncoder = .noticeEncoder) async throws -> Void {
    guard let notices = notices else {
      throw CancellationError()
    }
    return await save(notices, to: noticesFileName, with: encoder)
  }
}

let contactSettingsFileName = "contact-settings"
let favoriteChargesIdsFileName = "favorite-charge-Ids"
let userSettingsFilenName = "user-settings"
let noticesFileName = "notices"
