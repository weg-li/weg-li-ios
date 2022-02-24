import ComposableArchitecture
import Foundation

public extension UserDefaultsClient {
  static func live(
    userDefaults: UserDefaults = UserDefaults(suiteName: "group.weg-li")! // swiftlint:disable:this force_unwrapping
  ) -> Self {
    Self(
      boolForKey: userDefaults.bool(forKey:),
      dataForKey: { userDefaults.object(forKey: $0) as? Data },
      doubleForKey: userDefaults.double(forKey:),
      remove: { key in
          .fireAndForget {
            userDefaults.removeObject(forKey: key)
          }
      },
      setBool: { value, key in
          .fireAndForget {
            userDefaults.set(value, forKey: key)
          }
      },
      setData: { data, key in
          .fireAndForget {
            userDefaults.set(data, forKey: key)
          }
      },
      setDouble: { value, key in
          .fireAndForget {
            userDefaults.set(value, forKey: key)
          }
      }
    )
  }
}
