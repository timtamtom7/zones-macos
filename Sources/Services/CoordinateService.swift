import Foundation
import CoreLocation

final class CoordinateService {
    static let shared = CoordinateService()
    
    private let coordinates: [String: (lat: Double, lon: Double)] = [
        "America/Los_Angeles": (34.0, -118.0),
        "America/New_York": (40.0, -74.0),
        "America/Chicago": (41.0, -87.0),
        "America/Denver": (39.0, -105.0),
        "America/Anchorage": (61.0, -149.0),
        "America/Phoenix": (33.0, -112.0),
        "America/Toronto": (43.0, -79.0),
        "America/Vancouver": (49.0, -123.0),
        "America/Mexico_City": (19.0, -99.0),
        "America/Sao_Paulo": (-23.0, -46.0),
        "America/Buenos_Aires": (-34.0, -58.0),
        "Europe/London": (51.0, 0.0),
        "Europe/Paris": (49.0, 2.0),
        "Europe/Berlin": (52.0, 13.0),
        "Europe/Rome": (41.0, 12.0),
        "Europe/Madrid": (40.0, -3.0),
        "Europe/Amsterdam": (52.0, 4.0),
        "Europe/Moscow": (56.0, 37.0),
        "Europe/Istanbul": (41.0, 28.0),
        "Europe/Athens": (37.0, 23.0),
        "Europe/Stockholm": (59.0, 18.0),
        "Europe/Oslo": (59.0, 10.0),
        "Europe/Copenhagen": (55.0, 12.0),
        "Europe/Helsinki": (60.0, 25.0),
        "Europe/Warsaw": (52.0, 21.0),
        "Europe/Prague": (50.0, 14.0),
        "Europe/Vienna": (48.0, 16.0),
        "Europe/Zurich": (47.0, 8.0),
        "Europe/Dublin": (53.0, -6.0),
        "Europe/Brussels": (50.0, 4.0),
        "Asia/Tokyo": (35.0, 139.0),
        "Asia/Shanghai": (31.0, 121.0),
        "Asia/Singapore": (1.0, 104.0),
        "Asia/Hong_Kong": (22.0, 114.0),
        "Asia/Seoul": (37.0, 127.0),
        "Asia/Mumbai": (19.0, 72.0),
        "Asia/Kolkata": (19.0, 73.0),
        "Asia/Dubai": (25.0, 55.0),
        "Asia/Bangkok": (13.0, 100.0),
        "Asia/Jakarta": (-6.0, 106.0),
        "Asia/Manila": (14.0, 121.0),
        "Asia/Taipei": (25.0, 121.0),
        "Asia/Kuala_Lumpur": (3.0, 101.0),
        "Asia/Karachi": (24.0, 67.0),
        "Asia/Dhaka": (23.0, 90.0),
        "Asia/Ho_Chi_Minh": (10.0, 106.0),
        "Australia/Sydney": (-33.0, 151.0),
        "Australia/Melbourne": (-37.0, 145.0),
        "Australia/Perth": (-31.0, 115.0),
        "Australia/Brisbane": (-27.0, 153.0),
        "Pacific/Auckland": (-37.0, 175.0),
        "Pacific/Honolulu": (21.0, -157.0),
        "Pacific/Guam": (13.0, 144.0),
        "Africa/Cairo": (30.0, 31.0),
        "Africa/Lagos": (6.0, 3.0),
        "Africa/Johannesburg": (-26.0, 28.0),
        "Africa/Nairobi": (-1.0, 36.0),
        "Africa/Casablanca": (33.0, -7.0),
    ]
    
    private init() {}
    
    func coordinate(for timezoneIdentifier: String) -> (lat: Double, lon: Double)? {
        if let coord = coordinates[timezoneIdentifier] {
            return coord
        }
        if let tz = TimeZone(identifier: timezoneIdentifier) {
            let offset = Double(tz.secondsFromGMT()) / 3600.0
            return (20, offset * 15)
        }
        return nil
    }
    
    func coordinate2D(for timezoneIdentifier: String) -> CLLocationCoordinate2D {
        if let coord = coordinate(for: timezoneIdentifier) {
            return CLLocationCoordinate2D(latitude: coord.lat, longitude: coord.lon)
        }
        return CLLocationCoordinate2D(latitude: 0, longitude: 0)
    }
    
    func coordinateForCity(_ city: City) -> (lat: Double, lon: Double)? {
        coordinate(for: city.timezoneIdentifier)
    }
}
