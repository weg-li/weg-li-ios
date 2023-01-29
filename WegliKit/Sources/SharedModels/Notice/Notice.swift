import ComposableArchitecture
import Foundation

public struct Notice: Codable, Equatable, Identifiable {
  public var id: String { token ?? UUID().uuidString }
  
  public var token: String?
  public var status: Status?
  public var street: String?
  public var city: String?
  public var zip: String?
  public var latitude: Double?
  public var longitude: Double?
  public var registration: String?
  public var brand: String?
  public var color: String?
  public var charge: String?
  public var date: Date?
  public var duration: Int64?
  public var severity: String?
  public var note: String?
  public var createdAt: Date?
  public var updatedAt: Date?
  public var sentAt: Date?
  public var vehicleEmpty: Bool?
  public var hazardLights: Bool?
  public var expiredTuv: Bool?
  public var expiredEco: Bool?
  public var photos: [NoticePhoto]?
  
  public var time: String? {
    guard let duration = duration else {
      return nil
    }
    return Times.times[Int(duration)]
  }
  
  public var interval: String? {
    guard
      let date = date,
      let duration = duration,
      let interval = Times.interval(value: Int(duration), from: date)
    else { return nil }
    return DateIntervalFormatter.reportTimeFormatter.string(from: interval)
  }
  
  public init(
    token: String,
    status: Status,
    street: String,
    city: String,
    zip: String,
    latitude: Double,
    longitude: Double,
    registration: String,
    brand: String,
    color: String,
    charge: String,
    date: Date,
    duration: Int64,
    severity: String?,
    note: String,
    createdAt: Date,
    updatedAt: Date,
    sentAt: Date,
    vehicleEmpty: Bool = false,
    hazardLights: Bool = false,
    expiredTuv: Bool = false,
    expiredEco: Bool = false,
    photos: [NoticePhoto]
  ) {
    self.token = token
    self.status = status
    self.street = street
    self.city = city
    self.zip = zip
    self.latitude = latitude
    self.longitude = longitude
    self.registration = registration
    self.brand = brand
    self.color = color
    self.charge = charge
    self.date = date
    self.duration = duration
    self.severity = severity
    self.note = note
    self.createdAt = createdAt
    self.updatedAt = updatedAt
    self.sentAt = sentAt
    self.vehicleEmpty = vehicleEmpty
    self.hazardLights = hazardLights
    self.expiredTuv = expiredTuv
    self.expiredEco = expiredEco
    self.photos = photos
  }
  
  public enum Status: String, Codable, Comparable {
    case open
    case disabled
    case analyzing
    case shared
    
    public var displayTitle: String {
      switch self {
      case .open:
        return "offen"
      case .disabled:
        return "deaktiviert"
      case .analyzing:
        return "analysieren"
      case .shared:
        return "gemeldet"
      }
    }
    
    var sortOrderValue: Int {
      switch self {
      case .open:
        return 0
      case .disabled:
        return 3
      case .analyzing:
        return 2
      case .shared:
        return 1
      }
    }
    
    public static func < (lhs: Notice.Status, rhs: Notice.Status) -> Bool {
      lhs.sortOrderValue < rhs.sortOrderValue
    }
  }
}

public extension Notice {
  static let mock = Self(
    token: "123",
    status: .open,
    street: "",
    city: "",
    zip: "",
    latitude: 0,
    longitude: 0,
    registration: "",
    brand: "",
    color: "",
    charge: "",
    date: .distantFuture,
    duration: 0,
    severity: "",
    note: "",
    createdAt: .distantFuture,
    updatedAt: .distantFuture,
    sentAt: .distantFuture,
    photos: []
  )
}
