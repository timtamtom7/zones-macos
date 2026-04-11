import SwiftUI

struct AnalogClockView: View {
    let timeZone: TimeZone
    let size: CGFloat
    let showSecondHand: Bool
    let handColor: Color

    @State private var currentTime = Date()
    @State private var timer: Timer?
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        Canvas { context, size in
            let center = CGPoint(x: size.width / 2, y: size.height / 2)
            let radius = min(size.width, size.height) / 2 - 4

            let faceRect = CGRect(x: center.x - radius, y: center.y - radius, width: radius * 2, height: radius * 2)
            
            context.stroke(
                Circle().path(in: faceRect),
                with: .color(.secondary.opacity(0.3)),
                lineWidth: 1.5
            )

            for i in 0..<12 {
                let angle = Angle(degrees: Double(i) * 30 - 90)
                let innerRadius = radius - 8
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

                let lineWidth: CGFloat = i % 3 == 0 ? 2.5 : 1.5
                context.stroke(path, with: .color(.primary.opacity(0.6)), lineWidth: lineWidth)
            }

            var calendar = Calendar(identifier: .gregorian)
            calendar.timeZone = timeZone
            let components = calendar.dateComponents([.hour, .minute, .second], from: currentTime)
            let hours = Double(components.hour ?? 0)
            let minutes = Double(components.minute ?? 0)
            let seconds = Double(components.second ?? 0)

            let hourAngle = Angle(degrees: (hours.truncatingRemainder(dividingBy: 12)) * 30 + minutes * 0.5 - 90)
            let hourRadius = radius * 0.5
            drawHand(context: &context, center: center, length: hourRadius, angle: hourAngle, width: 3.5, color: handColor)

            let minuteAngle = Angle(degrees: minutes * 6 + seconds * 0.1 - 90)
            let minuteRadius = radius * 0.75
            drawHand(context: &context, center: center, length: minuteRadius, angle: minuteAngle, width: 2.5, color: handColor)

            // Respect Reduce Motion — hide second hand if animation is reduced
            if showSecondHand && !reduceMotion {
                let secondAngle = Angle(degrees: seconds * 6 - 90)
                let secondRadius = radius * 0.8
                drawHand(context: &context, center: center, length: secondRadius, angle: secondAngle, width: 1, color: .red)
            }

            let centerDot = Circle().path(in: CGRect(x: center.x - 4, y: center.y - 4, width: 8, height: 8))
            context.fill(centerDot, with: .color(.secondary.opacity(0.3)))
            context.stroke(centerDot, with: .color(handColor), lineWidth: 2)
        }
        .frame(width: size, height: size)
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
    @State private var timer: Timer?

    var body: some View {
        AnalogClockView(
            timeZone: timeZone,
            size: size,
            showSecondHand: false,
            handColor: .primary
        )
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
}
