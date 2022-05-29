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
    httpMethod: HTTPMethod = .get
  ) {
    self.endpoint = endpoint
    self.httpMethod = httpMethod
  }
}

public struct UploadImageRequest: APIRequest {
  public var queryItems: [URLQueryItem] = []
  public typealias ResponseDataType = [ImageUploadInput]
  public let endpoint: Endpoint
  public var headers: HTTPHeaders? = .contentTypeApplicationJSON
  public let httpMethod: HTTPMethod
  public var body: Data?
  public var imageData: Data?
  
  var convertToImageUploadInput: (PickerImageResult) -> ImageUploadInput? = { pickerResult in
    guard
      let fileURL = pickerResult.imageUrl,
      let fileData = try? Data(contentsOf: fileURL)
    else {
      return nil
    }
    
    return ImageUploadInput(
      filename: pickerResult.id,
      byteSize: fileURL.fileSize,
      checksum: fileData.md5DigestBase64()
    )
  }
  
  public init(
    endpoint: Endpoint = .uploads,
    httpMethod: HTTPMethod = .post,
    pickerResult: PickerImageResult
  ) {
    self.endpoint = endpoint
    self.httpMethod = httpMethod
    
    self.imageData = pickerResult.imageUrl.flatMap { try? Data(contentsOf: $0) }
    
    let input = convertToImageUploadInput(pickerResult)
    let bodyData = try? JSONEncoder.noticeEncoder.encode(input)
    self.body = bodyData
  }
}

public struct DirectUploadRequest: APIRequest {
  public var queryItems: [URLQueryItem] = []
  public typealias ResponseDataType = [ImageUploadInput]
  public let endpoint: Endpoint
  public var headers: HTTPHeaders?
  public let httpMethod: HTTPMethod = .put
  public var body: Data?
    
  public init(
    endpoint: Endpoint,
    queryItems: [URLQueryItem],
    body: Data?,
    headers: HTTPHeaders
  ) {
    self.endpoint = endpoint
    self.queryItems = queryItems
    self.body = body
    self.headers = headers
  }
}


extension Data {
  func md5DigestBase64() -> String {
    let digest = Insecure.MD5.hash(data: self)
    return Data(digest).base64EncodedString()
  }
}

extension URL {  
  var attributes: [FileAttributeKey : Any]? {
    do {
      return try FileManager.default.attributesOfItem(atPath: path)
    } catch let error as NSError {
      print("FileAttribute error: \(error)")
    }
    return nil
  }
  
  var fileSize: UInt64 { attributes?[.size] as? UInt64 ?? UInt64(0) }
}
