import Dependencies
import Network

extension DependencyValues {
  public var pathMonitorClient: PathMonitorClient {
    get { self[PathMonitorClient.self] }
    set { self[PathMonitorClient.self] = newValue }
  }
}

/// A client to monitor the apps connectivity
public struct PathMonitorClient {
  public var networkPathPublisher: @Sendable () async -> AsyncStream<NetworkPath>

  public var isNetworkAvailable = true
  
  public init(networkPathPublisher: @escaping @Sendable () async -> AsyncStream<NetworkPath>) {
    self.networkPathPublisher = networkPathPublisher
  }
}
