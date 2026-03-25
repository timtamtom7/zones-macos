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
            // Toolbar
            HStack {
                Text("World Map")
                    .font(.headline)
                Spacer()
                Button("Fit All") {
                    fitAllCities()
                }
                .buttonStyle(.plain)
                .foregroundColor(.accentColor)
            }
            .padding()
            .background(Color(NSColor.controlBackgroundColor))

            // Map
            ZStack {
                Map(coordinateRegion: $region, annotationItems: mapAnnotations) { annotation in
                    MapAnnotation(coordinate: annotation.coordinate) {
                        cityMarker(annotation)
                    }
                }
                .allowsHitTesting(true)
                .gesture(
                    DragGesture()
                        .onChanged { _ in }
                )

                // Day/night overlay
                dayNightOverlay
            }

            // City detail popover
            if let city = selectedCity {
                cityDetailBar(city)
            }
        }
        .onAppear {
            mapRenderer.updateCities(cities)
        }
    }

    private var mapAnnotations: [MapCityAnnotation] {
        cities.compactMap { city -> MapCityAnnotation? in
            guard let coord = coordinateForCity(city) else { return nil }
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
            "America/Chicago": (41.0, -87.0),
            "America/Denver": (39.0, -105.0),
            "Asia/Dubai": (25.0, 55.0),
            "Asia/Hong_Kong": (22.0, 114.0),
            "Europe/Berlin": (52.0, 13.0),
            "Europe/Moscow": (56.0, 37.0),
            "Asia/Seoul": (37.0, 127.0),
            "Asia/Kolkata": (19.0, 73.0),
        ]
        if let coord = coords[city.timezoneIdentifier] {
            return coord
        }
        if let tz = city.timezone {
            let offset = Double(tz.secondsFromGMT()) / 3600.0
            return (20, offset * 15)
        }
        return nil
    }

    @ViewBuilder
    private func cityMarker(_ annotation: MapCityAnnotation) -> some View {
        VStack(spacing: 2) {
            ZStack {
                Circle()
                    .fill(annotation.isDaytime ? Color.yellow : Color.indigo)
                    .frame(width: 16, height: 16)
                Circle()
                    .stroke(Color.white, lineWidth: 2)
                    .frame(width: 16, height: 16)
            }
            Text(annotation.name)
                .font(.caption2)
                .padding(.horizontal, 4)
                .padding(.vertical, 2)
                .background(Color(NSColor.windowBackgroundColor).opacity(0.8))
                .cornerRadius(4)
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

            // Night side
            HStack(spacing: 0) {
                if terminatorX > 0 {
                    Rectangle()
                        .fill(Color.black.opacity(0.3))
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
                Text(Self.formattedTime(for: tz)).font(.system(size: 24, weight: .medium, design: .monospaced))
            }
            Spacer()
            Text(city.name).font(.headline)
            if let abbrev = city.timezone?.abbreviation() {
                Text(abbrev).font(.caption).foregroundColor(.secondary)
            }
        }.padding().background(Color(NSColor.controlBackgroundColor))
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

final class WorldMapViewModel: ObservableObject {
    @Published var cities: [City] = []

    func updateCities(_ cities: [City]) {
        self.cities = cities
    }
}
