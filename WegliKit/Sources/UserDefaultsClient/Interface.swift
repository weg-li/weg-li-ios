import ComposableArchitecture
import Foundation
import Helper
import SharedModels

public struct UserDefaultsClient {
  public var boolForKey: (String) -> Bool
  public var dataForKey: (String) -> Data?
  public var doubleForKey: (String) -> Double
  public var remove: (String) -> Effect<Never, Never>
  public var setBool: (Bool, String) -> Effect<Never, Never>
  public var setData: (Data?, String) -> Effect<Never, Never>
  public var setDouble: (Double, String) -> Effect<Never, Never>
  
  public var contact: Contact? { try? dataForKey(contactKey)?.decoded()
  }
  
  public func setContact(_ contact: Contact) -> Effect<Never, Never> {
    let data = try? contact.encoded()
    return setData(data, contactKey)
  }
}

let contactKey = "contactKey"
