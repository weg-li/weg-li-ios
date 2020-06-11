import SwiftUI

struct EnvironmentContainer {
    let personalDataRepository: PersonsalDataRepository
    let dataStore: ImageDataStore
    let locationProvider: LocationProvider
    let geoCoder: GeoCodeProvider
    let exifReader: ExifReader
}
