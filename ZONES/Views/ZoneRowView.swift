import SwiftUI

struct ZoneRowView: View {
    let city: City
    let currentTime: Date
    let use24Hour: Bool

    private var formattedTime: String {
        TimeFormatterService.shared.formatTime(for: city, at: currentTime, use24Hour: use24Hour)
    }

    private var timezoneAbbr: String {
        TimeFormatterService.shared.formatTimezoneAbbreviation(for: city)
    }

    var body: some View {
        HStack {
            Text(city.flagEmoji)
                .font(.system(size: 16))

            VStack(alignment: .leading, spacing: 2) {
                Text(city.name)
                    .font(.system(size: 12, weight: .medium))
                Text(city.country)
                    .font(.system(size: 10))
                    .foregroundColor(.secondary)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 2) {
                Text(formattedTime)
                    .font(.system(size: 13, weight: .semibold, design: .monospaced))
                Text(timezoneAbbr)
                    .font(.system(size: 10))
                    .foregroundColor(.secondary)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .contentShape(Rectangle())
        .contextMenu {
            Button("Copy Time") {
                let pasteboard = NSPasteboard.general
                pasteboard.clearContents()
                pasteboard.setString(formattedTime, forType: .string)
            }
            Divider()
            Button("Remove") {
                // Will be handled by parent
            }
        }
    }
}
