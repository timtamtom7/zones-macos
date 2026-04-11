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
            HStack {
                Text(city.name)
                    .font(.headline)
                    .fontWeight(.semibold)
                Spacer()
                Button(action: { isPresented = false }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }

            TextField("Nickname", text: $nickname)
                .textFieldStyle(.plain)
                .padding(10)
                .background(.ultraThinMaterial)
                .clipShape(.rect(cornerRadius: 12, style: .continuous))

            Text("Display Mode")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Picker("Mode", selection: $selectedMode) {
                Text("Digital").tag(ClockDisplayMode.digital)
                Text("Analog").tag(ClockDisplayMode.analog)
                Text("Both").tag(ClockDisplayMode.both)
            }
            .pickerStyle(.segmented)

            Text("Color Label")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            HStack(spacing: 8) {
                ForEach(colors, id: \.self) { color in
                    Circle()
                        .fill(Color(hex: color) ?? .blue)
                        .frame(width: 24, height: 24)
                        .overlay(
                            Circle()
                                .stroke(selectedColor == color ? Color.white : Color.clear, lineWidth: 2)
                        )
                        .shadow(color: selectedColor == color ? Color(hex: color)?.opacity(0.5) ?? .clear : .clear, radius: 4)
                        .onTapGesture {
                            selectedColor = color
                        }
                }
            }

            Toggle("Hide from menu bar", isOn: $hideFromMenuBar)

            Button("Save") {
                saveSettings()
                isPresented = false
            }
            .buttonStyle(.bordered)
        }
        .padding(16)
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
