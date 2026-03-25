import AppIntents
import Foundation

struct WidgetConfigurationEntity: AppEntity {
    static var typeDisplayRepresentation: TypeDisplayRepresentation = "Widget Zone"
    static var defaultQuery = WidgetZoneQuery()
    
    var id: UUID
    var cityName: String
    var timezoneIdentifier: String
    
    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(title: "\(cityName)")
    }
}

struct WidgetZoneQuery: EntityQuery {
    func entities(for identifiers: [UUID]) async throws -> [WidgetConfigurationEntity] {
        return []
    }
    
    func suggestedEntities() async throws -> [WidgetConfigurationEntity] {
        return []
    }
}

struct WidgetShowDSTAppIntent: AppIntent {
    static var title: LocalizedStringResource = "Show DST in Widget"
    
    @Parameter(title: "Show DST")
    var showDST: Bool
    
    func perform() async throws -> some IntentResult {
        UserDefaults.standard.set(showDST, forKey: "widgetShowDST")
        return .result()
    }
}
