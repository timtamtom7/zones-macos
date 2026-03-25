import Foundation

class SettingsStore {
    private let db = DatabaseManager.shared

    func getString(forKey key: String) -> String? {
        return db.getSetting(forKey: key)
    }

    func set(_ value: String, forKey key: String) {
        db.setSetting(value, forKey: key)
    }

    func getBool(forKey key: String) -> Bool? {
        guard let val = getString(forKey: key) else { return nil }
        return val == "true"
    }

    func set(_ value: Bool, forKey key: String) {
        set(value ? "true" : "false", forKey: key)
    }

    func getInt(forKey key: String) -> Int? {
        guard let val = getString(forKey: key) else { return nil }
        return Int(val)
    }

    func set(_ value: Int, forKey key: String) {
        set(String(value), forKey: key)
    }
}
