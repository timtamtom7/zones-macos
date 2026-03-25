import Foundation
import AppIntents

// MARK: - Get Current Time Intent

struct GetCurrentTimeIntent: AppIntent {
    static var title: LocalizedStringResource = "Get Current Time"
    static var description = IntentDescription("Returns the current time in a specified timezone")
    
    @Parameter(title: "Timezone")
    var timezoneIdentifier: String
    
    static var parameterSummary: some ParameterSummary {
        Summary("Get current time in \(\.$timezoneIdentifier)")
    }
    
    func perform() async throws -> some IntentResult & ReturnsValue<String> {
        guard let timezone = TimeZone(identifier: timezoneIdentifier) else {
            return .result(value: "Invalid timezone")
        }
        
        let formatter = DateFormatter()
        formatter.timeZone = timezone
        formatter.dateFormat = "h:mm a"
        
        let timeString = formatter.string(from: Date())
        return .result(value: timeString)
    }
}

// MARK: - Convert Time Intent

struct ConvertTimeIntent: AppIntent {
    static var title: LocalizedStringResource = "Convert Time"
    static var description = IntentDescription("Converts a time from one timezone to another")
    
    @Parameter(title: "Time")
    var time: String
    
    @Parameter(title: "From Timezone")
    var fromTimezone: String
    
    @Parameter(title: "To Timezone")
    var toTimezone: String
    
    static var parameterSummary: some ParameterSummary {
        Summary("Convert \(\.$time) from \(\.$fromTimezone) to \(\.$toTimezone)")
    }
    
    func perform() async throws -> some IntentResult & ReturnsValue<String> {
        guard let fromTZ = TimeZone(identifier: fromTimezone),
              let toTZ = TimeZone(identifier: toTimezone) else {
            return .result(value: "Invalid timezone")
        }
        
        let inputFormatter = DateFormatter()
        inputFormatter.timeZone = fromTZ
        inputFormatter.dateFormat = "h:mm a"
        
        guard let date = inputFormatter.date(from: time) else {
            return .result(value: "Invalid time format")
        }
        
        let outputFormatter = DateFormatter()
        outputFormatter.timeZone = toTZ
        outputFormatter.dateFormat = "h:mm a"
        
        let convertedTime = outputFormatter.string(from: date)
        return .result(value: convertedTime)
    }
}

// MARK: - App Shortcuts Provider

struct ZONESShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: GetCurrentTimeIntent(),
            phrases: [
                "What time is it in \(.applicationName)",
                "Get current time in \(.applicationName)"
            ],
            shortTitle: "Get Current Time",
            systemImageName: "clock"
        )
        
        AppShortcut(
            intent: ConvertTimeIntent(),
            phrases: [
                "Convert time in \(.applicationName)",
                "Convert timezone in \(.applicationName)"
            ],
            shortTitle: "Convert Time",
            systemImageName: "arrow.left.arrow.right"
        )
    }
}
