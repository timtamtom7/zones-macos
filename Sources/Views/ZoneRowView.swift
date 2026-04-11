import SwiftUI

struct ZoneRowView: View {
    @EnvironmentObject var appState: AppState

    let city: City

    private let timeFormatter = TimeFormatterService.shared

    var body: some View {
        HStack(spacing: 12) {
            Text(timeString)
                .font(.system(size: 24, weight: .semibold, design: .monospaced))
                .foregroundStyle(city.displayColor ?? .primary)
                .frame(width: 120, alignment: .leading)

            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    if city.isLocal {
                        Circle()
                            .fill(.tint)
                            .frame(width: 8, height: 8)
                    }

                    if let color = city.displayColor {
                        Circle()
                            .fill(color)
                            .frame(width: 8, height: 8)
                    }

                    Text(city.isLocal ? "Local Time" : city.displayName)
                        .fontWeight(city.isLocal ? .semibold : .medium)
                }

                HStack(spacing: 6) {
                    Text(city.flagEmoji)
                        .font(.caption)

                    if !city.isLocal {
                        Text(city.country)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }

                    Text("·")
                        .foregroundStyle(.secondary)

                    Text(city.timezoneAbbreviation)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()

            Text(dateString)
                .font(.caption)
                .foregroundStyle(.secondary)
            
            if let dst = dstIndicator {
                Text(dst)
                    .font(.caption2)
                    .fontWeight(.medium)
                    .padding(.horizontal, 4)
                    .padding(.vertical, 2)
                    .background(Color.blue.opacity(0.2))
                    .foregroundStyle(.blue)
                    .clipShape(Capsule())
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 16)
        .background(city.isLocal ? Color.accentColor.opacity(0.08) : Color.clear)
        .clipShape(.rect(cornerRadius: 12, style: .continuous))
        .contentShape(Rectangle())
        .accessibilityElement(children: .combine)
        .accessibilityLabel(accessibilityDescription)
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
    
    private var dstIndicator: String? {
        guard let tz = city.timezone else { return nil }
        return tz.isDaylightSavingTime(for: appState.currentTime) ? "DST" : nil
    }

    private var accessibilityDescription: String {
        var parts: [String] = []
        parts.append(city.isLocal ? "Local time" : city.displayName)
        parts.append(timeString)
        if let dst = dstIndicator {
            parts.append(dst)
        }
        parts.append("on \(dateString)")
        return parts.joined(separator: ", ")
    }
}
