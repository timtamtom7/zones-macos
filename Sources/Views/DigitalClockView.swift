import SwiftUI

struct DigitalClockView: View {
    let timeZone: TimeZone
    let format: ClockFormat
    let color: Color

    @State private var currentTime = Date()

    private static let sharedTimer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        let timeString = ClockFormatService.shared.formatTime(currentTime, in: timeZone, format: format)

        Text(timeString)
            .font(digitalFont)
            .foregroundColor(color)
            .monospacedDigit()
            .onReceive(Self.sharedTimer) { time in
                currentTime = time
            }
    }

    private var digitalFont: Font {
        let size: CGFloat = format.showSeconds ? 18 : 22
        switch format.fontStyle {
        case .system:
            return .system(size: size, weight: .medium)
        case .monospaced:
            return .system(size: size, weight: .medium, design: .monospaced)
        case .rounded:
            return .system(size: size, weight: .medium, design: .rounded)
        }
    }
}
