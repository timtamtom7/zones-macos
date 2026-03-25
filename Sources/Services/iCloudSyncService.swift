import Foundation
import CloudKit

class iCloudSyncService: ObservableObject {
    static let shared = iCloudSyncService()
    
    private let container = CKContainer(identifier: "iCloud.com.zones.app")
    private let privateDatabase: CKDatabase
    
    @Published var syncStatus: SyncStatus = .idle
    @Published var lastSyncDate: Date?
    @Published var isEnabled: Bool = true
    
    enum SyncStatus: Equatable {
        case idle
        case syncing
        case success
        case error(String)
    }
    
    private init() {
        privateDatabase = container.privateCloudDatabase
        loadSyncPreference()
    }
    
    private func loadSyncPreference() {
        isEnabled = UserDefaults.standard.bool(forKey: "iCloudSyncEnabled")
    }
    
    func setSyncEnabled(_ enabled: Bool) {
        isEnabled = enabled
        UserDefaults.standard.set(enabled, forKey: "iCloudSyncEnabled")
        if enabled {
            syncAll()
        }
    }
    
    // MARK: - Sync Cities
    
    func syncCities(_ cities: [City]) async throws {
        guard isEnabled else { return }
        
        await MainActor.run { syncStatus = .syncing }
        
        do {
            let records = try await fetchAllRecords(ofType: "City")
            try await deleteStaleRecords(records: records, currentCities: cities)
            
            for city in cities {
                try await saveCityRecord(city)
            }
            
            await MainActor.run {
                syncStatus = .success
                lastSyncDate = Date()
            }
        } catch {
            await MainActor.run { syncStatus = .error(error.localizedDescription) }
            throw error
        }
    }
    
    private func saveCityRecord(_ city: City) async throws {
        let recordID = CKRecord.ID(recordName: city.id.uuidString)
        let record = CKRecord(recordType: "City", recordID: recordID)
        
        record["cityName"] = city.name as CKRecordValue
        record["timezoneIdentifier"] = city.timezoneIdentifier as CKRecordValue
        record["country"] = city.country as CKRecordValue
        record["sortOrder"] = city.sortOrder as CKRecordValue
        record["isLocal"] = city.isLocal as CKRecordValue
        record["isFavorite"] = city.isFavorite as CKRecordValue
        record["updatedAt"] = Date() as CKRecordValue
        
        _ = try await privateDatabase.save(record)
    }
    
    private func fetchAllRecords(ofType type: String) async throws -> [CKRecord] {
        let query = CKQuery(recordType: type, predicate: NSPredicate(value: true))
        let (results, _) = try await privateDatabase.records(matching: query)
        return results.compactMap { try? $0.1.get() }
    }
    
    private func deleteStaleRecords(records: [CKRecord], currentCities: [City]) async throws {
        let currentIDs = Set(currentCities.map { $0.id.uuidString })
        
        for record in records {
            if !currentIDs.contains(record.recordID.recordName) {
                try await privateDatabase.deleteRecord(withID: record.recordID)
            }
        }
    }
    
    // MARK: - Sync Settings
    
    func syncSettings(_ settings: [String: Any]) async throws {
        guard isEnabled else { return }
        
        let recordID = CKRecord.ID(recordName: "settings")
        let record = CKRecord(recordType: "Settings", recordID: recordID)
        
        for (key, value) in settings {
            record[key] = value as? CKRecordValue ?? (String(describing: value) as CKRecordValue)
        }
        
        _ = try await privateDatabase.save(record)
    }
    
    func fetchSettings() async throws -> [String: Any] {
        let recordID = CKRecord.ID(recordName: "settings")
        
        do {
            let record = try await privateDatabase.record(for: recordID)
            var settings: [String: Any] = [:]
            for key in record.allKeys() {
                settings[key] = record[key]
            }
            return settings
        } catch {
            return [:]
        }
    }
    
    // MARK: - Full Sync
    
    func syncAll() {
        Task {
            do {
                let cities = CityStore.shared.cities
                try await syncCities(cities)
                
                let settings: [String: Any] = [
                    "timeFormat": UserDefaults.standard.string(forKey: "timeFormat") ?? "12h",
                    "showDST": UserDefaults.standard.bool(forKey: "showDST")
                ]
                try await syncSettings(settings)
            } catch {
                print("Sync error: \(error)")
            }
        }
    }
}
