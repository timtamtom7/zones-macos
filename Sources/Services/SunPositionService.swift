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

        // Solar azimuth - using atan2 with X/Y components to avoid div-by-zero
        let cosHa = cos(haRad)
        let sinHa = sin(haRad)
        let cosLat = cos(latRad)
        let sinLat = sin(latRad)
        let cosDec = cos(decRad)
        let sinDec = sin(decRad)

        let azX = sinHa * cosDec
        let azY = cosHa * cosDec * sinLat - sinDec * cosLat
        var azimuth = atan2(azX, azY) * 180 / .pi

        // Normalize to 0-360
        if azimuth < 0 { azimuth += 360 }

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
            guard let coord = CoordinateService.shared.coordinateForCity(city) else { return nil }
            let isDaytime = SunPositionService.shared.isDaytime(latitude: coord.lat, longitude: coord.lon, date: Date())
            return MapCity(id: city.id.uuidString, name: city.name, coordinate: coord, isDaytime: isDaytime)
        }
    }
}
