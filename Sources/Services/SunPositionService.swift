import Foundation

struct SunPosition {
    var azimuth: Double
    var elevation: Double
}

final class SunPositionService {
    static let shared = SunPositionService()

    func calculateSunPosition(latitude: Double, longitude: Double, date: Date) -> SunPosition {
        let calendar = Calendar.current
        let dayOfYear = calendar.ordinality(of: .day, in: .year, for: date) ?? 1

        // Solar declination
        let declination = 23.45 * sin(Double(360 * (284 + dayOfYear) / 365) * .pi / 180)

        // Hour angle
        let hour = Double(calendar.component(.hour, from: date)) + Double(calendar.component(.minute, from: date)) / 60.0
        let hourAngle = 15 * (hour - 12)

        // Solar elevation
        let latRad = latitude * .pi / 180
        let decRad = declination * .pi / 180
        let haRad = hourAngle * .pi / 180

        let elevation = asin(sin(latRad) * sin(decRad) + cos(latRad) * cos(decRad) * cos(haRad)) * 180 / .pi

        // Solar azimuth
        let azimuth = atan2(sin(haRad), cos(haRad) * sin(latRad) / tan(decRad) - sin(latRad) * cos(haRad)) * 180 / .pi + 180

        return SunPosition(azimuth: azimuth, elevation: elevation)
    }

    func isDaytime(latitude: Double, longitude: Double, date: Date) -> Bool {
        let position = calculateSunPosition(latitude: latitude, longitude: longitude, date: date)
        return position.elevation > 0
    }
}

final class WorldMapRenderer {
    struct MapCity: Identifiable {
        let id: String
        let name: String
        let coordinate: (lat: Double, lon: Double)
        let isDaytime: Bool
    }

    func citiesToMapCities(_ cities: [City]) -> [MapCity] {
        cities.compactMap { city -> MapCity? in
            guard let tz = city.timezone else { return nil }
            let lat = latitudeForTimezone(tz.identifier)
            let lon = longitudeForTimezone(tz.identifier)
            let isDaytime = SunPositionService.shared.isDaytime(latitude: lat, longitude: lon, date: Date())
            return MapCity(id: city.id.uuidString, name: city.name, coordinate: (lat, lon), isDaytime: isDaytime)
        }
    }

    private func latitudeForTimezone(_ identifier: String) -> Double {
        let coords: [String: (Double, Double)] = [
            "America/Los_Angeles": (34.0, -118.0),
            "America/New_York": (40.0, -74.0),
            "Europe/London": (51.0, 0.0),
            "Europe/Paris": (49.0, 2.0),
            "Asia/Tokyo": (35.0, 139.0),
            "Asia/Shanghai": (31.0, 121.0),
            "Asia/Singapore": (1.0, 104.0),
            "Australia/Sydney": (-33.0, 151.0),
            "Pacific/Auckland": (-37.0, 175.0),
        ]
        if let coord = coords[identifier] {
            return coord.0
        }
        return 0
    }

    private func longitudeForTimezone(_ identifier: String) -> Double {
        let coords: [String: (Double, Double)] = [
            "America/Los_Angeles": (34.0, -118.0),
            "America/New_York": (40.0, -74.0),
            "Europe/London": (51.0, 0.0),
            "Europe/Paris": (49.0, 2.0),
            "Asia/Tokyo": (35.0, 139.0),
            "Asia/Shanghai": (31.0, 121.0),
            "Asia/Singapore": (1.0, 104.0),
            "Australia/Sydney": (-33.0, 151.0),
            "Pacific/Auckland": (-37.0, 175.0),
        ]
        if let coord = coords[identifier] {
            return coord.1
        }
        return 0
    }
}
