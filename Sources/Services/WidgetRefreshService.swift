import Foundation
import WidgetKit

enum WidgetError: LocalizedError {
    case appGroupNotAvailable
    case encodingFailed
    case writeFailed(Error)
    
    var errorDescription: String? {
        switch self {
        case .appGroupNotAvailable:
            return "App group not available"
        case .encodingFailed:
            return "Failed to encode widget data"
        case .writeFailed(let error):
            return "Failed to write widget zones: \(error.localizedDescription)"
        }
    }
}

class WidgetRefreshService {
    static let shared = WidgetRefreshService()
    
    private let appGroupID = "group.com.zones.app"
    
    private init() {}
    
    func updateWidgetZones(_ cities: [City]) throws {
        guard let containerURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroupID) else {
            throw WidgetError.appGroupNotAvailable
        }
        
        let fileURL = containerURL.appendingPathComponent("widget_zones.json")
        
        do {
            let data = try JSONEncoder().encode(cities)
            try data.write(to: fileURL)
            reloadWidgets()
        } catch let error as WidgetError {
            throw error
        } catch {
            throw WidgetError.writeFailed(error)
        }
    }
    
    func reloadWidgets() {
        WidgetCenter.shared.reloadAllTimelines()
    }
    
    func reloadTimeZoneWidget() {
        WidgetCenter.shared.reloadTimelines(ofKind: "TimeZoneWidget")
    }
    
    func reloadWorldClockWidget() {
        WidgetCenter.shared.reloadTimelines(ofKind: "WorldClockWidget")
    }
}
