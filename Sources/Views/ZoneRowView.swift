import SwiftUI

struct ZoneRowView: View {
    let city: City
    @EnvironmentObject var appState: AppState

    private let timeFormatter = TimeFormatterService.shared

    var body: some View {
        HStack(spacing: 12) {
            // Time
            Text(timeString)
                .font(.system(size: 24, weight: .medium, design: .monospaced))
                .frame(width: 120, alignment: .leading)

            // City info
            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 4) {
                    if city.isLocal {
                        Circle()
                            .fill(Color.accentColor)
                            .frame(width: 6, height: 6)
                    }

                    Text(city.isLocal ? "Local Time" : city.name)
                        .fontWeight(city.isLocal ? .semibold : .regular)
                }

                HStack(spacing: 4) {
                    Text(city.flagEmoji)
                        .font(.caption)

                    if !city.isLocal {
                        Text(city.country)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }

                    Text("·")
                        .foregroundColor(.secondary)

                    Text(city.timezoneAbbreviation)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            Spacer()

            // Date
            Text(dateString)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(city.isLocal ? Color.accentColor.opacity(0.05) : Color.clear)
        .contentShape(Rectangle())
    }

    private var timeString: String {
        timeFormatter.formatTimeWithSeconds(appState.currentTime, timezone: city.timezone ?? .current, use24Hour: appState.use24HourFormat)
    }

    private var dateString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE, MMM d"
        formatter.timeZone = city.timezone ?? .current
        return formatter.string(from: appState.currentTime)
    }
}
