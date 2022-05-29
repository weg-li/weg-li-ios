import Foundation

/// Error type to describe network related errors
public enum NetworkRequestError: LocalizedError, Equatable {
  case invalidRequest
  case unauthorized
  case badRequest
  case forbidden
  case notFound
  case error4xx(_ code: Int)
  case serverError
  case error5xx(_ code: Int)
  case decodingError
  case urlSessionFailed(_ error: URLError)
  case unknownError
}
