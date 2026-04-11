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
                if #available(macOS 14.0, *) {
                    macOS14Map
                } else {
                    macOS13Map
                }
            }
        }
        .clipShape(.rect(cornerRadius: 12, style: .continuous))
    }

    @available(macOS 14.0, *)
    private var macOS14Map: some View {
        Map {
            ForEach(cityAnnotations) { annotation in
                Annotation(annotation.name, coordinate: annotation.coordinate) {
                    Circle()
                        .fill(annotation.color)
                        .frame(width: 10, height: 10)
                        .overlay(
                            Circle()
                                .stroke(Color.white, lineWidth: 1)
                        )
                }
            }
        }
        .allowsHitTesting(false)
    }

    private var macOS13Map: some View {
        Map(coordinateRegion: $region, annotationItems: cityAnnotations) { annotation in
            MapMarker(coordinate: annotation.coordinate, tint: annotation.color)
        }
        .allowsHitTesting(false)
    }

    private var cityAnnotations: [CityAnnotation] {
        cities.compactMap { city -> CityAnnotation? in
            let coordinate = CoordinateService.shared.coordinate2D(for: city.timezoneIdentifier)
            let isDaytime = isCityDaytime(city)
            return CityAnnotation(
                id: city.id.uuidString,
                name: city.name,
                coordinate: coordinate,
                color: isDaytime ? .yellow : .blue
            )
        }
    }

    private func isCityDaytime(_ city: City) -> Bool {
        guard let tz = city.timezone else { return true }
        var calendar = Calendar(identifier: .gregorian)
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
