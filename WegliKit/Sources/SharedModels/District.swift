import Foundation
import Helper

public struct District: Equatable, Codable {
  public init(
    name: String,
    zip: String,
    email: String,
    latitude: Double,
    longitude: Double,
    personalEmail: Bool
  ) {
    self.name = name
    self.zip = zip
    self.email = email
    self.latitude = latitude
    self.longitude = longitude
    self.personalEmail = personalEmail
  }
  
  public let name: String
  public let zip: String
  public let email: String
  public let latitude: Double
  public let longitude: Double
  public let personalEmail: Bool
}
