import SwiftUI

struct EnvironmentContainer: EnvironmentKey {
    typealias Value = EnvironmentContainer
    static var defaultValue: EnvironmentContainer = EnvironmentContainer()
    
    var personalDataRepository = PersonsalDataRepository()
}

extension EnvironmentValues {
    var environment: EnvironmentContainer {
        get {
            return self[EnvironmentContainer.self]
        }
        set {
            self[EnvironmentContainer.self] = newValue
        }
    }
}
