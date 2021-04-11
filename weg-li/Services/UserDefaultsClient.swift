// Created for weg-li in 2021.

import ComposableArchitecture
import Foundation

struct UserDefaultsClient {
    var boolForKey: (String) -> Bool
    var dataForKey: (String) -> Data?
    var doubleForKey: (String) -> Double
    var remove: (String) -> Effect<Never, Never>
    var setBool: (Bool, String) -> Effect<Never, Never>
    var setData: (Data?, String) -> Effect<Never, Never>
    var setDouble: (Double, String) -> Effect<Never, Never>

    var contact: ContactState? { (try? dataForKey(contactKey)?.decoded())
    }

    func setContact(_ contact: ContactState) -> Effect<Never, Never> {
        let data = try? contact.encoded()
        return setData(data, contactKey)
    }

    var reports: [Report] {
        (try? dataForKey(reportsKey)?.decoded()) ?? []
    }

    func setReports(_ reports: [Report]) -> Effect<Never, Never> {
        let data = try? reports.encoded()
        return setData(data, reportsKey)
    }
}

private let reportsKey = "reportsKey"
private let contactKey = "contactKey"

extension UserDefaultsClient {
    static func live(userDefaults: UserDefaults = UserDefaults(suiteName: "group.weg-li")!) -> Self {
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

// Mock
extension UserDefaultsClient {
    static let noop = Self(
        boolForKey: { _ in false },
        dataForKey: { _ in nil },
        doubleForKey: { _ in 0 },
        remove: { _ in .none },
        setBool: { _, _ in .none },
        setData: { _, _ in .none },
        setDouble: { _, _ in .none }
    )
}
