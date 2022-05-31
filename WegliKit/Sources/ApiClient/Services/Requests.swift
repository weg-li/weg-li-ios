import Foundation
import SharedModels
import UIKit

/// A ApiRequest to POST a new notice to `/api/notices`
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

/// A ApiRequest to GET notices from `/api/notices`
public struct GetNoticesRequest: APIRequest {
  public var queryItems: [URLQueryItem] = []
  public typealias ResponseDataType = [Notice]
  public let endpoint: Endpoint
  public var headers: HTTPHeaders? = .contentTypeApplicationJSON
  public let httpMethod: HTTPMethod
  public var body: Data?
  
  public init(
    endpoint: Endpoint = .notices,
    httpMethod: HTTPMethod = .get
  ) {
    self.endpoint = endpoint
    self.httpMethod = httpMethod
  }
}

/// A APIRequest to upload images to the `/api/uploads` endpoint
public struct UploadImageRequest: APIRequest {
  public var queryItems: [URLQueryItem] = []
  public typealias ResponseDataType = [ImageUploadInput]
  public let endpoint: Endpoint
  public var headers: HTTPHeaders? = .contentTypeApplicationJSON
  public let httpMethod: HTTPMethod
  public var body: Data?
  public var imageData: Data?
    
  public init(
    endpoint: Endpoint = .uploads,
    httpMethod: HTTPMethod = .post,
    pickerResult: PickerImageResult
  ) {
    self.endpoint = endpoint
    self.httpMethod = httpMethod
    let input: ImageUploadInput? = .make(from: pickerResult)
    self.imageData = pickerResult.jpegData
    let bodyData = try? JSONEncoder.noticeEncoder.encode(input)
    self.body = bodyData
  }
}
