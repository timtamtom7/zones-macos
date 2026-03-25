import Foundation
import SQLite

class DatabaseManager {
    static let shared = DatabaseManager()

    private var db: Connection?
    private let dbPath: String

    private init() {
        let appSupport = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let zonesDir = appSupport.appendingPathComponent("ZONES", isDirectory: true)
        try? FileManager.default.createDirectory(at: zonesDir, withIntermediateDirectories: true)
        dbPath = zonesDir.appendingPathComponent("zones.db").path
    }

    func setup() {
        do {
            db = try Connection(dbPath)
            try createTables()
        } catch {
            print("Database setup failed: \(error)")
        }
    }

    func getConnection() -> Connection? {
        return db
    }

    private func createTables() throws {
        guard let db = db else { return }

        let cities = Table("cities")
        let id = SQLite.Expression<String>("id")
        let name = SQLite.Expression<String>("name")
        let country = SQLite.Expression<String>("country")
        let timezoneId = SQLite.Expression<String>("timezone_id")
        let sortOrder = SQLite.Expression<Int>("sort_order")
        let isLocal = SQLite.Expression<Bool>("is_local")
        let isFavorite = SQLite.Expression<Bool>("is_favorite")

        let settings = Table("settings")
        let key = SQLite.Expression<String>("key")
        let value = SQLite.Expression<String>("value")

        try db.run(cities.create(ifNotExists: true) { t in
            t.column(id, primaryKey: true)
            t.column(name)
            t.column(country)
            t.column(timezoneId)
            t.column(sortOrder)
            t.column(isLocal, defaultValue: false)
            t.column(isFavorite, defaultValue: false)
        })

        try db.run(settings.create(ifNotExists: true) { t in
            t.column(key, primaryKey: true)
            t.column(value)
        })
    }
}
