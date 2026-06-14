import Foundation

/// Centralizes `UserDefaults` access behind typed helpers and named keys, so callers
/// never deal with bare string keys or repeat the JSON encode/decode dance.
///
/// Instances are created with an injectable `UserDefaults` suite, which lets tests
/// run against an isolated suite instead of `.standard`.
struct UserDefaultsStore {
    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    enum Key: String {
        case spoilerMode
        case recentSearches
        case recentlyViewed
        case watchlist
        case appearance
    }

    // MARK: - Bool

    func bool(_ key: Key, default defaultValue: Bool) -> Bool {
        defaults.object(forKey: key.rawValue) as? Bool ?? defaultValue
    }

    func set(_ value: Bool, for key: Key) {
        defaults.set(value, forKey: key.rawValue)
    }

    // MARK: - String / String array

    func string(_ key: Key) -> String? {
        defaults.string(forKey: key.rawValue)
    }

    func set(_ value: String, for key: Key) {
        defaults.set(value, forKey: key.rawValue)
    }

    func stringArray(_ key: Key) -> [String] {
        defaults.stringArray(forKey: key.rawValue) ?? []
    }

    func set(_ value: [String], for key: Key) {
        defaults.set(value, forKey: key.rawValue)
    }

    // MARK: - Codable

    func codable<T: Decodable>(_ type: T.Type, for key: Key) -> T? {
        guard let data = defaults.data(forKey: key.rawValue) else { return nil }
        return try? JSONDecoder().decode(T.self, from: data)
    }

    func setCodable<T: Encodable>(_ value: T, for key: Key) {
        if let data = try? JSONEncoder().encode(value) {
            defaults.set(data, forKey: key.rawValue)
        }
    }

    // MARK: - Removal

    func remove(_ key: Key) {
        defaults.removeObject(forKey: key.rawValue)
    }
}
