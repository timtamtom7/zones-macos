import SwiftUI
import MapKit

struct WorldMapView: View {
    let cities: [City]
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 20, longitude: 0),
        span: MKCoordinateSpan(latitudeDelta: 100, longitudeDelta: 180)
    )
    @State private var selectedCity: City?
    @StateObject private var mapRenderer = WorldMapViewModel()

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("World Map")
                    .font(.headline)
                    .fontWeight(.semibold)
                Spacer()
                Button("Fit All") {
                    fitAllCities()
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Fit all cities on map")
                .accessibilityHint("Zooms and pans the map to show all your added cities")
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(.regularMaterial)

            ZStack {
                Map {
                    ForEach(mapAnnotations) { annotation in
                        Annotation(annotation.name, coordinate: annotation.coordinate) {
                            cityMarker(annotation)
                        }
                    }
                }

                dayNightOverlay
            }

            if let city = selectedCity {
                cityDetailBar(city)
            }
        }
        .clipShape(.rect(cornerRadius: 12, style: .continuous))
        .shadow(color: .black.opacity(0.12), radius: 10, x: 0, y: 3)
        .onAppear {
            mapRenderer.updateCities(cities)
        }
    }

    private var mapAnnotations: [MapCityAnnotation] {
        cities.compactMap { city -> MapCityAnnotation? in
            guard let coord = CoordinateService.shared.coordinateForCity(city) else { return nil }
            let isDaytime = SunPositionService.shared.isDaytime(latitude: coord.lat, longitude: coord.lon, date: Date())
            return MapCityAnnotation(
                id: city.id.uuidString,
                name: city.name,
                coordinate: CLLocationCoordinate2D(latitude: coord.lat, longitude: coord.lon),
                isDaytime: isDaytime
            )
        }
    }

    private func coordinateForCity(_ city: City) -> (lat: Double, lon: Double)? {
        CoordinateService.shared.coordinateForCity(city)
    }

    @ViewBuilder
    private func cityMarker(_ annotation: MapCityAnnotation) -> some View {
        VStack(spacing: 4) {
            ZStack {
                Circle()
                    .fill(annotation.isDaytime ? Color.yellow : Color.indigo)
                    .frame(width: 18, height: 18)
                Circle()
                    .stroke(Color.white, lineWidth: 2)
                    .frame(width: 18, height: 18)
            }
            Text(annotation.name)
                .font(.caption2)
                .fontWeight(.medium)
                .padding(.horizontal, 6)
                .padding(.vertical, 3)
                .background(.ultraThinMaterial)
                .clipShape(.capsule)
        }
        .onTapGesture {
            if let city = cities.first(where: { $0.id.uuidString == annotation.id }) {
                selectedCity = city
            }
        }
    }

    private var dayNightOverlay: some View {
        GeometryReader { geometry in
            let now = Date()
            let hour = Calendar.current.component(.hour, from: now)

            let terminatorX = CGFloat(hour) / 24.0 * geometry.size.width

            HStack(spacing: 0) {
                if terminatorX > 0 {
                    Rectangle()
                        .fill(.black.opacity(0.25))
                        .frame(width: terminatorX)
                }
                Spacer()
            }
        }
        .allowsHitTesting(false)
    }

    @ViewBuilder
    private func cityDetailBar(_ city: City) -> some View {
        HStack {
            if let tz = city.timezone {
                Text(Self.formattedTime(for: tz))
                    .font(.system(size: 24, weight: .semibold, design: .monospaced))
            }
            Spacer()
            Text(city.name)
                .font(.headline)
            if let abbrev = city.timezone?.abbreviation() {
                Text(abbrev)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(.regularMaterial)
    }
    
    private static func formattedTime(for tz: TimeZone) -> String {
        let formatter = DateFormatter()
        formatter.timeZone = tz
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: Date())
    }

    private func fitAllCities() {
        guard !cities.isEmpty else { return }
        var minLat = 90.0, maxLat = -90.0, minLon = 180.0, maxLon = -180.0
        for city in cities {
            if let coord = coordinateForCity(city) {
                minLat = min(minLat, coord.lat)
                maxLat = max(maxLat, coord.lat)
                minLon = min(minLon, coord.lon)
                maxLon = max(maxLon, coord.lon)
            }
        }
        let center = CLLocationCoordinate2D(latitude: (minLat + maxLat) / 2, longitude: (minLon + maxLon) / 2)
        let span = MKCoordinateSpan(latitudeDelta: max(maxLat - minLat + 20, 40), longitudeDelta: max(maxLon - minLon + 20, 40))
        region = MKCoordinateRegion(center: center, span: span)
    }
}

struct MapCityAnnotation: Identifiable {
    let id: String
    let name: String
    let coordinate: CLLocationCoordinate2D
    let isDaytime: Bool
}

@MainActor
final class WorldMapViewModel: ObservableObject {
    @Published var cities: [City] = []

    func updateCities(_ cities: [City]) {
        self.cities = cities
    }
}
