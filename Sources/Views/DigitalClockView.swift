import SwiftUI

struct DigitalClockView: View {
    let timeZone: TimeZone
    let format: ClockFormat
    let color: Color

    @State private var currentTime = Date()
    @State private var timer: Timer?

    var body: some View {
        let timeString = ClockFormatService.shared.formatTime(currentTime, in: timeZone, format: format)

        Text(timeString)
            .font(digitalFont)
            .foregroundStyle(color)
            .monospacedDigit()
            .onAppear {
                timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
                    currentTime = Date()
                }
            }
            .onDisappear {
                timer?.invalidate()
                timer = nil
            }
    }

    private var digitalFont: Font {
        let size: CGFloat = format.showSeconds ? 18 : 22
        switch format.fontStyle {
        case .system:
            return .system(size: size, weight: .semibold)
        case .monospaced:
            return .system(size: size, weight: .semibold, design: .monospaced)
        case .rounded:
            return .system(size: size, weight: .semibold, design: .rounded)
        }
    }
}
