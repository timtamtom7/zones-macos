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
        let cities = CityStore.shared.cities
        return cities
            .filter { identifiers.contains($0.id) }
            .map { WidgetConfigurationEntity(id: $0.id, cityName: $0.name, timezoneIdentifier: $0.timezoneIdentifier) }
    }
    
    func suggestedEntities() async throws -> [WidgetConfigurationEntity] {
        return CityStore.shared.cities.prefix(10).map {
            WidgetConfigurationEntity(id: $0.id, cityName: $0.name, timezoneIdentifier: $0.timezoneIdentifier)
        }
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
