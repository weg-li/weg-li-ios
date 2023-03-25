import Foundation
import SharedModels
import XCTest

@MainActor
final class NoticeCodingTests: XCTestCase {
  func test_noticeDecoding() throws {
    let rawValue = """
    {
        "token": "e47f97a803f6a9cb1b4e325bef77c5b1",
        "status": "analyzing",
        "street": "string",
        "city": "string",
        "zip": "string",
        "latitude": 51.5,
        "longitude": 10.5,
        "registration": "string",
        "color": "gold_yellow",
        "brand": "Abarth",
        "charge": {
          "tbnr": "141775",
          "description": "Sie parkten auf einem Radweg (Zeichen 237) und behinderten +) dadurch Andere.",
          "fine": "70.0",
          "bkat": "§ 41 Abs. 1 iVm Anlage 2, § 1 Abs. 2, § 49 StVO; § 24 Abs. 1, 3 Nr. 5 StVG; 52a.1 BKat; § 19 OWiG",
          "penalty": null,
          "fap": "B",
          "points": 1,
          "valid_from": "2021-11-09T00:00:00.000+01:00",
          "valid_to": null,
          "implementation": 2,
          "classification": 5,
          "variant_table_id": 741033,
          "rule_id": 39,
          "table_id": null,
          "required_refinements": "00000000000000000000000000000000",
          "number_required_refinements": 1,
          "max_fine": "0.0",
          "created_at": "2021-11-11T16:52:43.506+01:00",
          "updated_at": "2021-11-11T16:52:43.506+01:00"
        },
        "tbnr": "141775",
        "date": "2022-05-20T12:01:19.816+02:00",
        "duration": 1,
        "severity": 1,
        "photos": [],
        "created_at": "2022-05-20T12:09:01.914+02:00",
        "updated_at": "2022-05-20T12:09:01.914+02:00",
        "sent_at": null,
        "vehicle_empty": false,
        "hazard_lights": false,
        "expired_tuv": false,
        "expired_eco": false,
        "over_2_8_tons": false
    }
    """.data(using: .utf8)!
    
    do {
      _ = try JSONDecoder.noticeDecoder.decode(Notice.self, from: rawValue)
    } catch {
      print(error)
      XCTFail(error.localizedDescription)
    }
  }
}
