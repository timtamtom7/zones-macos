import Foundation

final class WeatherInsights {
    static let shared = WeatherInsights()
    
    private let weatherService = WeatherService.shared
    
    private init() {}
    
    func suggestTravelTime(for city: City, date: Date) async -> String {
        do {
            let weather = try await weatherService.fetchWeather(for: city)
            return travelSuggestion(for: weather, on: date)
        } catch {
            return "Check current weather conditions before traveling"
        }
    }
    
    private func travelSuggestion(for weather: WeatherInfo, on date: Date) -> String {
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: date)
        
        switch weather.condition {
        case .stormy:
            return "Expect travel delays due to storms. Leave 45-60 minutes early"
        case .rainy:
            if hour >= 7 && hour <= 9 || hour >= 17 && hour <= 19 {
                return "Rush hour rain expected. Leave 30 minutes early"
            }
            return "Rain expected. Consider leaving 15-20 minutes early"
        case .snowy:
            return "Snow conditions likely. Leave 45-60 minutes early and drive carefully"
        case .foggy:
            return "Foggy conditions. Leave 20-30 minutes early for visibility"
        case .cloudy, .partlyCloudy:
            if hour >= 7 && hour <= 9 || hour >= 17 && hour <= 19 {
                return "Cloudy rush hour. Leave 15 minutes early"
            }
            return "Pleasant weather expected. No travel adjustment needed"
        case .sunny:
            if hour >= 7 && hour <= 9 || hour >= 17 && hour <= 19 {
                return "Clear skies but busy roads. Leave 10-15 minutes early"
            }
            return "Great weather! Normal travel time should suffice"
        case .unknown:
            return "Check weather before departing"
        }
    }
}
