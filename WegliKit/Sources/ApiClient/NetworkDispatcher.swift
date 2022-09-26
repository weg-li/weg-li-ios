import Combine
import Foundation

/// A client to dispatch network request to URLSession
public struct NetworkDispatcher {
  var urlSession: () -> URLSession

  public init(urlSession: @escaping () -> URLSession) {
    self.urlSession = urlSession
  }

  func dispatch(request: URLRequest) async throws -> Data {
    let (data, response) = try await urlSession().data(for: request)
    if let response = response as? HTTPURLResponse, !response.isSuccessful {
      throw httpError(response.statusCode)
    }
    return data
  }
}

extension NetworkDispatcher {
  /// Parses a HTTP StatusCode and returns a proper error
  /// - Parameter statusCode: HTTP status code
  /// - Returns: Mapped Error
  private func httpError(_ statusCode: Int) -> NetworkRequestError {
    switch statusCode {
    case 400: return .badRequest
    case 401: return .unauthorized
    case 403: return .forbidden
    case 404: return .notFound
    case 402, 405...499: return .error4xx(statusCode)
    case 500: return .serverError
    case 501...599: return .error5xx(statusCode)
    default: return .unknownError
    }
  }

  /// Parses URLSession Publisher errors and return proper ones
  /// - Parameter error: URLSession publisher error
  /// - Returns: Readable NetworkRequestError
  private func handleError(_ error: Error) -> NetworkRequestError {
    switch error {
    case is Swift.DecodingError:
      return .decodingError
    case let urlError as URLError:
      return .urlSessionFailed(urlError)
    case let error as NetworkRequestError:
      return error
    default:
      return .unknownError
    }
  }
}

public extension NetworkDispatcher {
  static let live = Self(urlSession: { .shared })
  static let noop = Self(urlSession: { URLSession(configuration: .default) })
}

public struct ApiError: Codable, Error, Equatable, LocalizedError {
  public let errorDump: String
  public let file: String
  public let line: UInt
  public let message: String

  public init(
    error: Error,
    file: StaticString = #fileID,
    line: UInt = #line
  ) {
    var string = ""
    dump(error, to: &string)
    self.errorDump = string
    self.file = String(describing: file)
    self.line = line
    self.message = String(describing: error)
  }

  public var errorDescription: String? {
    message
  }
}

extension HTTPURLResponse {
  var isSuccessful: Bool {
    (200...299).contains(statusCode)
  }
}
