import SwiftUI

struct EnvironmentContainer {
    let dataStore: ImageDataStore
    let locationProvider: LocationProvider
    let geoCoder: GeoCodeProvider
    let exifReader: ExifReader
}
