import SwiftUI
import MapKit

struct WorldMapMiniView: View {
    let cities: [City]

    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 20, longitude: 0),
        span: MKCoordinateSpan(latitudeDelta: 120, longitudeDelta: 180)
    )

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Map(coordinateRegion: $region, annotationItems: cityAnnotations) { annotation in
                    MapAnnotation(coordinate: annotation.coordinate) {
                        Circle()
                            .fill(annotation.color)
                            .frame(width: 10, height: 10)
                            .overlay(
                                Circle()
                                    .stroke(Color.white, lineWidth: 1)
                            )
                    }
                }
                .allowsHitTesting(false)
            }
        }
        .cornerRadius(8)
    }

    private var cityAnnotations: [CityAnnotation] {
        cities.compactMap { city -> CityAnnotation? in
            let coordinate = coordinateForTimezone(city.timezoneIdentifier)
            let isDaytime = isCityDaytime(city)
            return CityAnnotation(
                id: city.id.uuidString,
                name: city.name,
                coordinate: coordinate,
                color: isDaytime ? .yellow : .blue
            )
        }
    }

    private func coordinateForTimezone(_ identifier: String) -> CLLocationCoordinate2D {
        // Approximate coordinates for common timezones
        let coords: [String: CLLocationCoordinate2D] = [
            "America/Los_Angeles": CLLocationCoordinate2D(latitude: 34, longitude: -118),
            "America/New_York": CLLocationCoordinate2D(latitude: 40, longitude: -74),
            "Europe/London": CLLocationCoordinate2D(latitude: 51, longitude: 0),
            "Europe/Paris": CLLocationCoordinate2D(latitude: 49, longitude: 2),
            "Asia/Tokyo": CLLocationCoordinate2D(latitude: 35, longitude: 139),
            "Asia/Shanghai": CLLocationCoordinate2D(latitude: 31, longitude: 121),
            "Asia/Singapore": CLLocationCoordinate2D(latitude: 1, longitude: 104),
            "Australia/Sydney": CLLocationCoordinate2D(latitude: -33, longitude: 151),
            "Pacific/Auckland": CLLocationCoordinate2D(latitude: -37, longitude: 175),
            "America/Chicago": CLLocationCoordinate2D(latitude: 41, longitude: -87),
            "America/Denver": CLLocationCoordinate2D(latitude: 39, longitude: -105),
            "Asia/Dubai": CLLocationCoordinate2D(latitude: 25, longitude: 55),
            "Asia/Hong_Kong": CLLocationCoordinate2D(latitude: 22, longitude: 114),
            "Europe/Berlin": CLLocationCoordinate2D(latitude: 52, longitude: 13),
            "Europe/Moscow": CLLocationCoordinate2D(latitude: 56, longitude: 37),
            "Asia/Seoul": CLLocationCoordinate2D(latitude: 37, longitude: 127),
            "Asia/Kolkata": CLLocationCoordinate2D(latitude: 19, longitude: 73),
        ]

        if let coord = coords[identifier] {
            return coord
        }

        // For unknown timezones, derive from offset
        guard let tz = TimeZone(identifier: identifier) else {
            return CLLocationCoordinate2D(latitude: 0, longitude: 0)
        }
        let offset = Double(tz.secondsFromGMT()) / 3600.0
        return CLLocationCoordinate2D(latitude: 20, longitude: offset * 15)
    }

    private func isCityDaytime(_ city: City) -> Bool {
        guard let tz = city.timezone else { return true }
        var calendar = Calendar.current
        calendar.timeZone = tz
        let hour = calendar.component(.hour, from: Date())
        return hour >= 6 && hour < 18
    }
}

struct CityAnnotation: Identifiable {
    let id: String
    let name: String
    let coordinate: CLLocationCoordinate2D
    let color: Color
}
