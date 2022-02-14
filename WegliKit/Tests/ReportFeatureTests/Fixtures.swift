// Created for weg-li in 2021.

import Foundation
import SharedModels

enum DistrictFixtures {
  static let districts = [
    District(
      name: "Berlin",
      zip: "10629",
      email: "Anzeige@bowi.berlin.de",
      latitude: 45.45,
      longitude: 34.43,
      personalEmail: true
    ),
    District(
      name: "Dortmund",
      zip: "44287",
      email: "fremdanzeigen.verkehrsueberwachung@stadtdo.de",
      latitude: 45.45,
      longitude: 34.43,
      personalEmail: false
    )
  ]
}
