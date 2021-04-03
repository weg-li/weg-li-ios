// Created for weg-li in 2021.

import Foundation

@propertyWrapper
struct UserDefault<Value: Codable> {
    let key: String
    let defaultValue: Value

    var wrappedValue: Value {
        get {
            return UserDefaults.standard.object(forKey: key) as? Value ?? defaultValue
        }
        set {
            UserDefaults.standard.set(newValue, forKey: key)
        }
    }
}

@propertyWrapper
struct Storage<T: Codable> {
    private let key: String
    private let defaultValue: T
    private let defaults: UserDefaults

    init(key: String, defaultValue: T, defaults: UserDefaults = .standard) {
        self.key = key
        self.defaultValue = defaultValue
        self.defaults = defaults
    }

    var wrappedValue: T {
        get {
            // Read value from UserDefaults
            guard let data = defaults.object(forKey: key) as? Data else {
                // Return defaultValue when no data in UserDefaults
                return defaultValue
            }
            // Convert data to the desire data type
            return (try? data.decoded()) ?? defaultValue
        }
        set {
            // Convert newValue to data
            let data = try? newValue.encoded()
            // Set value to UserDefaults
            defaults.set(data, forKey: key)
        }
    }
}

private extension Data {
    func decoded<T: Decodable>(decoder: JSONDecoder = JSONDecoder()) throws -> T {
        try decoder.decode(T.self, from: self)
    }
}

private extension Encodable {
    func encoded(encoder: JSONEncoder = JSONEncoder()) throws -> Data {
        try encoder.encode(self)
    }
}
