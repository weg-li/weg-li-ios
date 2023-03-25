import Foundation

public struct NoticeCharge: Codable, Hashable {  
  public let tbnr: String
  public var description: String?
  public var fine: String?
  public var bkat: String?
  public var penalty: String?
  public var fap: String?
  public var points: Int?
  public var validFrom: Date?
  public var validTo: Date?
  public var implementation: Int?
  public var classification: Int?
  public var variantTableId: Int?
  public var ruleId: Int?
  public var tableId: Int?
  public var requiredRefinements: String?
  public var numberRequiredRefinements: Int?
  public var maxFine: String?
  public var createAt: Date?
  public var updatedAt: Date?
  
  public init(
    tbnr: String,
    description: String? = nil,
    fine: String? = nil,
    bkat: String? = nil,
    penalty: String? = nil,
    fap: String? = nil,
    points: Int? = nil,
    validFrom: Date? = nil,
    validTo: Date? = nil,
    implementation: Int? = nil,
    classification: Int? = nil,
    variantTableId: Int? = nil,
    ruleId: Int? = nil,
    tableId: Int? = nil,
    requiredRefinements: String? = nil,
    numberRequiredRefinements: Int? = nil,
    maxFine: String? = nil,
    createAt: Date? = nil,
    updatedAt: Date? = nil
  ) {
    self.tbnr = tbnr
    self.description = description
    self.fine = fine
    self.bkat = bkat
    self.penalty = penalty
    self.fap = fap
    self.points = points
    self.validFrom = validFrom
    self.validTo = validTo
    self.implementation = implementation
    self.classification = classification
    self.variantTableId = variantTableId
    self.ruleId = ruleId
    self.tableId = tableId
    self.requiredRefinements = requiredRefinements
    self.numberRequiredRefinements = numberRequiredRefinements
    self.maxFine = maxFine
    self.createAt = createAt
    self.updatedAt = updatedAt
  }
}
