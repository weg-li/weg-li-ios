import Dependencies
import Foundation

// MARK: Live

extension FileClient: DependencyKey {
  public static var liveValue = Self.live
  
  static var live: Self {
    let documentDirectory = FileManager.default
      .urls(for: .documentDirectory, in: .userDomainMask)
      .first!

    return Self(
      removeItem: { url in
        try? FileManager.default.removeItem(at: url)
      },
      delete: { fileName in
        try? FileManager.default.removeItem(
          at:
            documentDirectory
            .appendingPathComponent(fileName)
            .appendingPathExtension(fileExtensionType)
        )
      },
      load: { fileName in
        try Data(
          contentsOf:
            documentDirectory
            .appendingPathComponent(fileName)
            .appendingPathExtension(fileExtensionType)
        )
      },
      save: { fileName, data in
        Task {
          _ = try? data.write(
            to:
              documentDirectory
              .appendingPathComponent(fileName)
              .appendingPathExtension(fileExtensionType)
          )
        }
      }
    )
  }
}

let fileExtensionType = "json"
