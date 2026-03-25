import SwiftUI

struct AnalogClockView: View {
    let timeZone: TimeZone
    let size: CGFloat
    let showSecondHand: Bool
    let handColor: Color

    @State private var currentTime = Date()

    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        Canvas { context, size in
            let center = CGPoint(x: size.width / 2, y: size.height / 2)
            let radius = min(size.width, size.height) / 2 - 4

            // Clock face
            let faceRect = CGRect(x: center.x - radius, y: center.y - radius, width: radius * 2, height: radius * 2)
            context.stroke(
                Circle().path(in: faceRect),
                with: .color(.secondary.opacity(0.3)),
                lineWidth: 1
            )

            // Hour markers
            for i in 0..<12 {
                let angle = Angle(degrees: Double(i) * 30 - 90)
                let innerRadius = radius - 6
                let outerRadius = radius - 2

                let inner = CGPoint(
                    x: center.x + innerRadius * cos(CGFloat(angle.radians)),
                    y: center.y + innerRadius * sin(CGFloat(angle.radians))
                )
                let outer = CGPoint(
                    x: center.x + outerRadius * cos(CGFloat(angle.radians)),
                    y: center.y + outerRadius * sin(CGFloat(angle.radians))
                )

                var path = Path()
                path.move(to: inner)
                path.addLine(to: outer)

                let lineWidth: CGFloat = i % 3 == 0 ? 2 : 1
                context.stroke(path, with: .color(.secondary.opacity(0.5)), lineWidth: lineWidth)
            }

            // Calculate time
            let calendar = Calendar.current
            let components = calendar.dateComponents(in: timeZone, from: currentTime)
            let hours = Double(components.hour ?? 0)
            let minutes = Double(components.minute ?? 0)
            let seconds = Double(components.second ?? 0)

            // Hour hand
            let hourAngle = Angle(degrees: (hours.truncatingRemainder(dividingBy: 12)) * 30 + minutes * 0.5 - 90)
            let hourRadius = radius * 0.5
            drawHand(context: &context, center: center, length: hourRadius, angle: hourAngle, width: 3, color: handColor)

            // Minute hand
            let minuteAngle = Angle(degrees: minutes * 6 + seconds * 0.1 - 90)
            let minuteRadius = radius * 0.75
            drawHand(context: &context, center: center, length: minuteRadius, angle: minuteAngle, width: 2, color: handColor)

            // Second hand
            if showSecondHand {
                let secondAngle = Angle(degrees: seconds * 6 - 90)
                let secondRadius = radius * 0.8
                drawHand(context: &context, center: center, length: secondRadius, angle: secondAngle, width: 1, color: .red)
            }

            // Center dot
            let centerDot = Circle().path(in: CGRect(x: center.x - 3, y: center.y - 3, width: 6, height: 6))
            context.fill(centerDot, with: .color(handColor))
        }
        .frame(width: size, height: size)
        .onReceive(timer) { time in
            currentTime = time
        }
    }

    private func drawHand(context: inout GraphicsContext, center: CGPoint, length: CGFloat, angle: Angle, width: CGFloat, color: Color) {
        let end = CGPoint(
            x: center.x + length * cos(CGFloat(angle.radians)),
            y: center.y + length * sin(CGFloat(angle.radians))
        )

        var path = Path()
        path.move(to: center)
        path.addLine(to: end)
        context.stroke(path, with: .color(color), lineWidth: width)
    }
}

struct CompactAnalogClock: View {
    let timeZone: TimeZone
    let size: CGFloat

    @State private var currentTime = Date()
    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        AnalogClockView(
            timeZone: timeZone,
            size: size,
            showSecondHand: false,
            handColor: .primary
        )
        .onReceive(timer) { time in
            currentTime = time
        }
    }
}
