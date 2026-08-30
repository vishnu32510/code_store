import Foundation
import UIKit

/// Universal communication bridge for decoding Flutter data and image assets in iOS WidgetKit extensions.
public struct WidgetBridge {
    /// The App Group ID suite used to read shared UserDefaults and files.
    public static var appGroupId: String = "group.com.nungu.codestore"

    /// Shared UserDefaults instance tied to the App Group container.
    public static var userDefaults: UserDefaults? {
        UserDefaults(suiteName: appGroupId)
    }

    /// Decodes any Codable model synchronized from Flutter via `HomeWidgetService.syncModel()`.
    public static func decode<T: Decodable>(_ type: T.Type, forKey key: String) -> T? {
        guard let jsonString = userDefaults?.string(forKey: key),
              let data = jsonString.data(using: .utf8) else {
            return nil
        }
        return try? JSONDecoder().decode(T.self, from: data)
    }

    /// Reads a string value from shared storage.
    public static func string(forKey key: String, fallback: String = "") -> String {
        userDefaults?.string(forKey: key) ?? fallback
    }

    /// Reads an integer value from shared storage.
    public static func int(forKey key: String, fallback: Int = 0) -> Int {
        userDefaults?.object(forKey: key) as? Int ?? fallback
    }

    /// Reads a boolean value from shared storage.
    public static func bool(forKey key: String, fallback: Bool = false) -> Bool {
        userDefaults?.object(forKey: key) as? Bool ?? fallback
    }

    /// Reads a double / float value from shared storage.
    public static func double(forKey key: String, fallback: Double = 0.0) -> Double {
        userDefaults?.object(forKey: key) as? Double ?? fallback
    }

    /// Loads an off-screen Flutter rendered image snapshot from disk.
    public static func image(forKey key: String) -> UIImage? {
        guard let path = userDefaults?.string(forKey: key),
              !path.isEmpty,
              FileManager.default.fileExists(atPath: path) else {
            return nil
        }
        return UIImage(contentsOfFile: path)
    }

    /// Retrieves an action URL for deep linking.
    public static func actionUrl(forKey key: String) -> URL? {
        guard let uriString = userDefaults?.string(forKey: "\(key)_action_uri"),
              !uriString.isEmpty else {
            return nil
        }
        return URL(string: uriString)
    }
}
