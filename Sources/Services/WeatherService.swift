import Foundation

struct WeatherInfo: Codable {
    let temperature: Int
    let condition: WeatherCondition
    let icon: String

    enum WeatherCondition: String, Codable {
        case sunny = "Sunny"
        case partlyCloudy = "Partly Cloudy"
        case cloudy = "Cloudy"
        case rainy = "Rainy"
        case stormy = "Stormy"
        case snowy = "Snowy"
        case foggy = "Foggy"
        case unknown = "Unknown"
    }
}

final class WeatherService {
    static let shared = WeatherService()

    private var cache: [String: (weather: WeatherInfo, fetchedAt: Date)] = [:]
    private let cacheExpiry: TimeInterval = 30 * 60

    func fetchWeather(for city: City) async throws -> WeatherInfo {
        if let cached = cache[city.id.uuidString],
           Date().timeIntervalSince(cached.fetchedAt) < cacheExpiry {
            return cached.weather
        }

        let urlString = "https://wttr.in/\(city.name.replacingOccurrences(of: " ", with: "_"))?format=j1"
        guard let url = URL(string: urlString) else {
            throw WeatherError.invalidURL
        }

        let (data, _) = try await URLSession.shared.data(from: url)

        if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
           let currentCondition = (json["current_condition"] as? [[String: Any]])?.first,
           let tempC = currentCondition["temp_C"],
           let weatherCode = (currentCondition["weatherCode"] as? String) ?? (currentCondition["weatherCode"] as? Int).map({ String($0) }) {
            let condition = conditionFromCode(weatherCode)
            let info = WeatherInfo(
                temperature: Int(tempC as? String ?? "0") ?? 0,
                condition: condition,
                icon: iconForCondition(condition)
            )
            cache[city.id.uuidString] = (info, Date())
            return info
        }

        return WeatherInfo(temperature: 20, condition: .unknown, icon: "questionmark.circle")
    }

    private func conditionFromCode(_ code: String) -> WeatherInfo.WeatherCondition {
        guard let codeInt = Int(code) else { return .unknown }
        switch codeInt {
        case 113: return .sunny
        case 116: return .partlyCloudy
        case 119, 122: return .cloudy
        case 200...299: return .stormy
        case 300...399: return .rainy
        case 500...599: return .rainy
        case 600...699: return .snowy
        case 700...799: return .foggy
        default: return .unknown
        }
    }

    private func iconForCondition(_ condition: WeatherInfo.WeatherCondition) -> String {
        switch condition {
        case .sunny: return "sun.max.fill"
        case .partlyCloudy: return "cloud.sun.fill"
        case .cloudy: return "cloud.fill"
        case .rainy: return "cloud.rain.fill"
        case .stormy: return "cloud.bolt.fill"
        case .snowy: return "snow"
        case .foggy: return "cloud.fog.fill"
        case .unknown: return "questionmark.circle"
        }
    }

    enum WeatherError: Error {
        case invalidURL
        case networkError
    }
}
