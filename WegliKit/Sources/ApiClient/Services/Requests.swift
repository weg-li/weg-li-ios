import Foundation
import SharedModels
import UIKit

public extension Request {
  /// Represents a POST ApiRequest to submit a new notice to `/api/notices`
  static func createNotice(body: Data?) -> Self {
    .post(.notices, body: body)
  }
  
  /// Represents a GET ApiRequest to get all notices `/api/notices`
  static func getNotices(forceReload: Bool) -> Self {
    var request = get(.notices)
    request.cachePolicy = forceReload ? .reloadIgnoringLocalCacheData : .useProtocolCachePolicy
    return request
  }
}
