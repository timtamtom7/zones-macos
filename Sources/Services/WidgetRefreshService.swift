import Foundation
import WidgetKit

class WidgetRefreshService {
    static let shared = WidgetRefreshService()
    
    private let appGroupID = "group.com.zones.app"
    
    private init() {}
    
    func updateWidgetZones(_ cities: [City]) {
        guard let containerURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroupID) else {
            return
        }
        
        let fileURL = containerURL.appendingPathComponent("widget_zones.json")
        
        do {
            let data = try JSONEncoder().encode(cities)
            try data.write(to: fileURL)
            reloadWidgets()
        } catch {
            print("Failed to write widget zones: \(error)")
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
