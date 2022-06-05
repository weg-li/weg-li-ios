import Foundation
import SharedModels
import XCTest

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
        "charge": "Parken auf einem unbeschilderten Radweg",
        "date": "2022-05-20T12:01:19.816+02:00",
        "duration": 1,
        "severity": "standard",
        "photos": [],
        "created_at": "2022-05-20T12:09:01.914+02:00",
        "updated_at": "2022-05-20T12:09:01.914+02:00",
        "sent_at": null,
        "vehicle_empty": false,
        "hazard_lights": false,
        "expired_tuv": false,
        "expired_eco": false
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
