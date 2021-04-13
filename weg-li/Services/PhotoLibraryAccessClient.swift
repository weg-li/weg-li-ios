// Created for weg-li in 2021.

import ComposableArchitecture
import Foundation
import Photos

typealias PhotoLibraryAuthorizationStatus = PHAuthorizationStatus

struct PhotoLibraryAccessClient {
    var requestAuthorization: () -> Effect<PhotoLibraryAuthorizationStatus, Never>
    var authorizationStatus: () -> PhotoLibraryAuthorizationStatus
}

extension PhotoLibraryAccessClient {
    static func live(accessLevel: PHAccessLevel = .readWrite) -> Self {
        Self(
            requestAuthorization: {
                .future { promise in
                    PHPhotoLibrary.requestAuthorization(for: accessLevel) { status in
                        promise(.success(status))
                    }
                }
            },
            authorizationStatus: {
                PHPhotoLibrary.authorizationStatus(for: accessLevel)
            }
        )
    }

    static let noop = Self(
        requestAuthorization: { .none },
        authorizationStatus: { .notDetermined }
    )
}
