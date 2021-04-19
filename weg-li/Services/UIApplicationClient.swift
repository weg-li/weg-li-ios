// Created for weg-li in 2021.

import ComposableArchitecture
import UIKit

struct UIApplicationClient {
    var open: (URL, [UIApplication.OpenExternalURLOptionsKey: Any]) -> Effect<Bool, Never>
    var openSettingsURLString: () -> String
}

extension UIApplicationClient {
    static let live = Self(
        open: { url, options in
            .future { callback in
                UIApplication.shared.open(url, options: options) { bool in
                    callback(.success(bool))
                }
            }
        },
        openSettingsURLString: { UIApplication.openSettingsURLString }
    )
    
    static let noop = Self(
        open: { _, _ in .none },
        openSettingsURLString: { "" }
    )
}
