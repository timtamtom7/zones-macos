import Foundation
import CloudKit

final class ZoneSyncService {
    static let shared = ZoneSyncService()
    
    @Published var isSyncing = false
    @Published var lastSyncDate: Date?
    @Published var isEnabled: Bool = true
    
    private let container: CKContainer
    private let privateDatabase: CKDatabase
    
    private init() {
        container = CKContainer(identifier: "iCloud.com.zones.app")
        privateDatabase = container.privateCloudDatabase
        loadSettings()
    }
    
    private func loadSettings() {
        isEnabled = UserDefaults.standard.bool(forKey: "zones_iCloudSyncEnabled")
    }
    
    func setEnabled(_ enabled: Bool) {
        isEnabled = enabled
        UserDefaults.standard.set(enabled, forKey: "zones_iCloudSyncEnabled")
    }
    
    // MARK: - City Sync
    
    func syncCities() async throws {
        guard isEnabled else { return }
        
        await MainActor.run { isSyncing = true }
        defer { Task { @MainActor in isSyncing = false } }
        
        let cities = loadLocalCities()
        for city in cities {
            try await saveCity(city)
        }
        
        await MainActor.run { lastSyncDate = Date() }
    }
    
    private func saveCity(_ city: SyncedCity) async throws {
        let record = CKRecord(recordType: "City")
        record["cityId"] = city.id.uuidString as CKRecordValue
        record["name"] = city.name as CKRecordValue
        record["timezone"] = city.timezone as CKRecordValue
        record["country"] = city.country as CKRecordValue
        record["order"] = city.order as CKRecordValue
        
        try await privateDatabase.save(record)
    }
    
    func fetchCities() async throws -> [SyncedCity] {
        let query = CKQuery(recordType: "City", predicate: NSPredicate(value: true))
        query.sortDescriptors = [NSSortDescriptor(key: "order", ascending: true)]
        
        let (results, _) = try await privateDatabase.records(matching: query)
        
        return results.compactMap { _, result -> SyncedCity? in
            guard case .success(let record) = result,
                  let idString = record["cityId"] as? String,
                  let id = UUID(uuidString: idString),
                  let name = record["name"] as? String,
                  let timezone = record["timezone"] as? String,
                  let country = record["country"] as? String else {
                return nil
            }
            
            return SyncedCity(
                id: id,
                name: name,
                timezone: timezone,
                country: country,
                order: (record["order"] as? Int) ?? 0
            )
        }
    }
    
    // MARK: - Settings Sync
    
    func syncSettings() async throws {
        guard isEnabled else { return }
        
        let settings = loadLocalSettings()
        let record = CKRecord(recordType: "Settings")
        record["settingsId"] = "main" as CKRecordValue
        record["theme"] = settings.theme as CKRecordValue
        record["showSeconds"] = settings.showSeconds as CKRecordValue
        record["use24Hour"] = settings.use24Hour as CKRecordValue
        
        try await privateDatabase.save(record)
    }
    
    private func loadLocalCities() -> [SyncedCity] {
        guard let data = UserDefaults.standard.data(forKey: "zones_cities"),
              let cities = try? JSONDecoder().decode([SyncedCity].self, from: data) else {
            return []
        }
        return cities
    }
    
    private func loadLocalSettings() -> ZoneSettings {
        ZoneSettings(
            theme: UserDefaults.standard.string(forKey: "zones_theme") ?? "system",
            showSeconds: UserDefaults.standard.bool(forKey: "zones_showSeconds"),
            use24Hour: UserDefaults.standard.bool(forKey: "zones_use24Hour")
        )
    }
}

// MARK: - Models

struct SyncedCity: Codable {
    let id: UUID
    var name: String
    var timezone: String
    var country: String
    var order: Int
}

struct ZoneSettings: Codable {
    var theme: String
    var showSeconds: Bool
    var use24Hour: Bool
}
