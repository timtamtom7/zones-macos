import SwiftUI

struct CityDetailPopover: View {
    let city: City
    @Binding var settings: CitySettings
    @Binding var isPresented: Bool
    @State private var nickname: String
    @State private var selectedMode: ClockDisplayMode
    @State private var selectedColor: String
    @State private var hideFromMenuBar: Bool

    private let colors = ["#007AFF", "#34C759", "#FF9500", "#FF3B30", "#AF52DE", "#5856D6", "#FF2D55", "#FFCC00"]

    init(city: City, settings: Binding<CitySettings>, isPresented: Binding<Bool>) {
        self.city = city
        self._settings = settings
        self._isPresented = isPresented
        self._nickname = State(initialValue: settings.wrappedValue.nickname ?? city.name)
        self._selectedMode = State(initialValue: settings.wrappedValue.clockFormat.displayMode)
        self._selectedColor = State(initialValue: settings.wrappedValue.colorLabel)
        self._hideFromMenuBar = State(initialValue: settings.wrappedValue.isHiddenFromMenuBar)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // City name
            HStack {
                Text(city.name)
                    .font(.headline)
                Spacer()
                Button(action: { isPresented = false }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                }
                .buttonStyle(.plain)
            }

            TextField("Nickname", text: $nickname)
                .textFieldStyle(.roundedBorder)

            // Display mode
            Text("Display Mode")
                .font(.subheadline)
                .foregroundColor(.secondary)

            Picker("Mode", selection: $selectedMode) {
                Text("Digital").tag(ClockDisplayMode.digital)
                Text("Analog").tag(ClockDisplayMode.analog)
                Text("Both").tag(ClockDisplayMode.both)
            }
            .pickerStyle(.segmented)

            // Color label
            Text("Color Label")
                .font(.subheadline)
                .foregroundColor(.secondary)

            HStack(spacing: 8) {
                ForEach(colors, id: \.self) { color in
                    Circle()
                        .fill(Color(hex: color) ?? .blue)
                        .frame(width: 20, height: 20)
                        .overlay(
                            Circle()
                                .stroke(selectedColor == color ? Color.white : Color.clear, lineWidth: 2)
                        )
                        .onTapGesture {
                            selectedColor = color
                        }
                }
            }

            // Hide from menu bar
            Toggle("Hide from menu bar", isOn: $hideFromMenuBar)

            Button("Save") {
                saveSettings()
                isPresented = false
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
        .frame(width: 280)
    }

    private func saveSettings() {
        settings = CitySettings(
            id: settings.id,
            cityId: city.id.uuidString,
            nickname: nickname.isEmpty ? nil : nickname,
            clockFormat: ClockFormat(
                displayMode: selectedMode,
                digitalFormat: settings.clockFormat.digitalFormat,
                use24Hour: settings.clockFormat.use24Hour,
                showSeconds: settings.clockFormat.showSeconds,
                showTimezoneAbbreviation: settings.clockFormat.showTimezoneAbbreviation,
                fontStyle: settings.clockFormat.fontStyle
            ),
            colorLabel: selectedColor,
            isHiddenFromMenuBar: hideFromMenuBar,
            updatedAt: Date()
        )
    }
}

extension Color {
    init?(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")

        var rgb: UInt64 = 0
        guard Scanner(string: hexSanitized).scanHexInt64(&rgb) else { return nil }

        self.init(
            red: Double((rgb & 0xFF0000) >> 16) / 255,
            green: Double((rgb & 0x00FF00) >> 8) / 255,
            blue: Double(rgb & 0x0000FF) / 255
        )
    }
}
