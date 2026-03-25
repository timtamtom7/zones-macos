import Foundation
import SQLite3

class DatabaseManager {
    static let shared = DatabaseManager()

    private var db: OpaquePointer?
    private let dbPath: String

    private init() {
        let fileManager = FileManager.default
        let appSupport = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let appFolder = appSupport.appendingPathComponent("ZONES", isDirectory: true)

        do {
            try fileManager.createDirectory(at: appFolder, withIntermediateDirectories: true)
        } catch {
            print("Failed to create app support directory: \(error)")
        }

        dbPath = appFolder.appendingPathComponent("zones.db").path
        openDatabase()
        createTables()
    }

    private func openDatabase() {
        if sqlite3_open(dbPath, &db) != SQLITE_OK {
            print("Error opening database")
        }
    }

    private func createTables() {
        let createCitiesTable = """
            CREATE TABLE IF NOT EXISTS cities (
                id TEXT PRIMARY KEY,
                name TEXT NOT NULL,
                country TEXT NOT NULL,
                timezone_id TEXT NOT NULL,
                sort_order INTEGER NOT NULL,
                is_local INTEGER NOT NULL DEFAULT 0,
                is_favorite INTEGER NOT NULL DEFAULT 0
            );
        """

        let createSettingsTable = """
            CREATE TABLE IF NOT EXISTS settings (
                key TEXT PRIMARY KEY,
                value TEXT NOT NULL
            );
        """

        execute(createCitiesTable)
        execute(createSettingsTable)
    }

    private func execute(_ sql: String) {
        var statement: OpaquePointer?
        if sqlite3_prepare_v2(db, sql, -1, &statement, nil) == SQLITE_OK {
            sqlite3_step(statement)
        } else {
            print("Error executing SQL: \(sql)")
        }
        sqlite3_finalize(statement)
    }

    // MARK: - Cities

    func loadCities() -> [City] {
        var cities: [City] = []
        let query = "SELECT * FROM cities ORDER BY sort_order ASC;"

        var statement: OpaquePointer?
        if sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK {
            while sqlite3_step(statement) == SQLITE_ROW {
                if let city = cityFromStatement(statement) {
                    cities.append(city)
                }
            }
        }
        sqlite3_finalize(statement)
        return cities
    }

    private func cityFromStatement(_ statement: OpaquePointer?) -> City? {
        guard let stmt = statement else { return nil }

        guard let idStr = sqlite3_column_text(stmt, 0),
              let nameStr = sqlite3_column_text(stmt, 1),
              let countryStr = sqlite3_column_text(stmt, 2),
              let tzStr = sqlite3_column_text(stmt, 3) else {
            return nil
        }

        let id = String(cString: idStr)
        let name = String(cString: nameStr)
        let country = String(cString: countryStr)
        let timezoneId = String(cString: tzStr)
        let sortOrder = Int(sqlite3_column_int(stmt, 4))
        let isLocal = sqlite3_column_int(stmt, 5) != 0
        let isFavorite = sqlite3_column_int(stmt, 6) != 0

        return City(
            id: UUID(uuidString: id) ?? UUID(),
            name: name,
            country: country,
            timezoneIdentifier: timezoneId,
            sortOrder: sortOrder,
            isLocal: isLocal,
            isFavorite: isFavorite
        )
    }

    func saveCity(_ city: City) {
        let sql = """
            INSERT OR REPLACE INTO cities (id, name, country, timezone_id, sort_order, is_local, is_favorite)
            VALUES (?, ?, ?, ?, ?, ?, ?);
        """

        var statement: OpaquePointer?
        if sqlite3_prepare_v2(db, sql, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_text(statement, 1, city.id.uuidString, -1, nil)
            sqlite3_bind_text(statement, 2, city.name, -1, nil)
            sqlite3_bind_text(statement, 3, city.country, -1, nil)
            sqlite3_bind_text(statement, 4, city.timezoneIdentifier, -1, nil)
            sqlite3_bind_int(statement, 5, Int32(city.sortOrder))
            sqlite3_bind_int(statement, 6, city.isLocal ? 1 : 0)
            sqlite3_bind_int(statement, 7, city.isFavorite ? 1 : 0)
            sqlite3_step(statement)
        }
        sqlite3_finalize(statement)
    }

    func deleteCity(_ city: City) {
        let sql = "DELETE FROM cities WHERE id = ?;"

        var statement: OpaquePointer?
        if sqlite3_prepare_v2(db, sql, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_text(statement, 1, city.id.uuidString, -1, nil)
            sqlite3_step(statement)
        }
        sqlite3_finalize(statement)
    }

    // MARK: - Settings

    func getSetting(forKey key: String) -> String? {
        let sql = "SELECT value FROM settings WHERE key = ?;"
        var result: String?

        var statement: OpaquePointer?
        if sqlite3_prepare_v2(db, sql, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_text(statement, 1, key, -1, nil)
            if sqlite3_step(statement) == SQLITE_ROW {
                if let val = sqlite3_column_text(statement, 0) {
                    result = String(cString: val)
                }
            }
        }
        sqlite3_finalize(statement)
        return result
    }

    func setSetting(_ value: String, forKey key: String) {
        let sql = "INSERT OR REPLACE INTO settings (key, value) VALUES (?, ?);"

        var statement: OpaquePointer?
        if sqlite3_prepare_v2(db, sql, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_text(statement, 1, key, -1, nil)
            sqlite3_bind_text(statement, 2, value, -1, nil)
            sqlite3_step(statement)
        }
        sqlite3_finalize(statement)
    }

    deinit {
        sqlite3_close(db)
    }
}
