import CryptoKit
import Foundation
import SharedModels
import UIKit

public struct SubmitNoticeRequest: APIRequest {
  public var queryItems: [URLQueryItem] = []
  public typealias ResponseDataType = Notice
  public let endpoint: Endpoint
  public var headers: HTTPHeaders? = .contentTypeApplicationJSON
  public let httpMethod: HTTPMethod
  public var body: Data?
  
  public init(
    endpoint: Endpoint = .notices,
    httpMethod: HTTPMethod = .post,
    body: Data?
  ) {
    self.endpoint = endpoint
    self.httpMethod = httpMethod
    self.body = body
  }
}

public struct GetNoticesRequest: APIRequest {
  public var queryItems: [URLQueryItem] = []
  public typealias ResponseDataType = [Notice]
  public let endpoint: Endpoint
  public var headers: HTTPHeaders? = .contentTypeApplicationJSON
  public let httpMethod: HTTPMethod
  public var body: Data?
  
  public init(
    endpoint: Endpoint = .notices,
    httpMethod: HTTPMethod = .get,
    body: Data? = nil
  ) {
    self.endpoint = endpoint
    self.httpMethod = httpMethod
    self.body = body
  }
}

public struct UploadImageRequest: APIRequest {
  public var queryItems: [URLQueryItem] = []
  public typealias ResponseDataType = [ImageUploadInput]
  public let endpoint: Endpoint
  public var headers: HTTPHeaders? = .contentTypeApplicationJSON
  public let httpMethod: HTTPMethod
  public var body: Data?
  
  var convert: (UIImage?, String) -> ImageUploadInput? = { image, filename in
    guard
      let image = image,
      let jpegData = image.jpegData(compressionQuality: 95)
    else {
      return nil
    }
    let checksum = jpegData.base64EncodedString().MD5
    return ImageUploadInput(
      filename: filename.appending(".jpg"),
      byteSize: UInt64(checksum.utf8.count),
      checksum: checksum
    )
  }
  
  public init(
    endpoint: Endpoint = .uploads,
    httpMethod: HTTPMethod = .post,
    pickerResult: PickerImageResult
  ) {
    self.endpoint = endpoint
    self.httpMethod = httpMethod
    let input = convert(pickerResult.asUIImage, pickerResult.id)
    let bodyData = try? JSONEncoder.noticeEncoder.encode(input)
    self.body = bodyData
  }
}

private let apiTokenKey = "X-API-KEY"

extension String {
  var MD5: String {
    let computed = Insecure.MD5.hash(data: self.data(using: .utf8)!)
    return computed.map { String(format: "%02hhx", $0) }.joined()
  }
}
