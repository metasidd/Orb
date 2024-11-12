import SwiftUI

struct WavyBlobView: View {
    @Binding var isAnimating: Bool
    @State private var animationStartDate: Date?
    @State private var accumulatedTime: Double = 0

    @State private var points: [CGPoint] = (0..<6).map { index in
        let angle = (Double(index) / 6) * 2 * .pi
        return CGPoint(
            x: 0.5 + cos(angle) * 0.9,
            y: 0.5 + sin(angle) * 0.9
        )
    }

    private let color: Color
    private let loopDuration: Double

    init(isAnimating: Binding<Bool>, color: Color, loopDuration: Double = 1) {
        self._isAnimating = isAnimating
        self.color = color
        self.loopDuration = loopDuration
    }

    var body: some View {
        TimelineView(.animation) { timeline in
            let date = timeline.date

            // Compute the angle based on whether the animation is active
            let angle: Double = {
                if let startDate = animationStartDate {
                    let elapsedTime = date.timeIntervalSince(startDate)
                    return ((accumulatedTime + elapsedTime) / loopDuration).truncatingRemainder(dividingBy: 1)
                        * 2 * .pi
                } else {
                    return (accumulatedTime / loopDuration).truncatingRemainder(dividingBy: 1) * 2 * .pi
                }
            }()

            Canvas { context, size in
                var path = Path()
                let center = CGPoint(x: size.width / 2, y: size.height / 2)
                let radius = min(size.width, size.height) * 0.45

                // Move points with larger variations using sine for smooth looping
                let adjustedPoints = points.enumerated().map { index, point in
                    let phaseOffset = Double(index) * .pi / 3
                    let xOffset = sin(angle + phaseOffset) * 0.15
                    let yOffset = cos(angle + phaseOffset) * 0.15
                    return CGPoint(
                        x: (point.x - 0.5 + xOffset) * radius + center.x,
                        y: (point.y - 0.5 + yOffset) * radius + center.y
                    )
                }

                // Start the path
                path.move(to: adjustedPoints[0])

                // Create smooth curves between points
                for i in 0 ..< adjustedPoints.count {
                    let next = (i + 1) % adjustedPoints.count

                    // Calculate the angle between points
                    let currentAngle = atan2(
                        adjustedPoints[i].y - center.y,
                        adjustedPoints[i].x - center.x
                    )
                    let nextAngle = atan2(
                        adjustedPoints[next].y - center.y,
                        adjustedPoints[next].x - center.x
                    )

                    // Create perpendicular handles
                    let handleLength = radius * 0.33

                    let control1 = CGPoint(
                        x: adjustedPoints[i].x + cos(currentAngle + .pi / 2) * handleLength,
                        y: adjustedPoints[i].y + sin(currentAngle + .pi / 2) * handleLength
                    )

                    let control2 = CGPoint(
                        x: adjustedPoints[next].x + cos(nextAngle - .pi / 2) * handleLength,
                        y: adjustedPoints[next].y + sin(nextAngle - .pi / 2) * handleLength
                    )

                    path.addCurve(
                        to: adjustedPoints[next],
                        control1: control1,
                        control2: control2
                    )
                }

                context.fill(path, with: .color(color))
            }
        }
        .onAppear {
            if isAnimating {
                animationStartDate = Date()
            }
        }
        .onChange(of: isAnimating) { newValue in
            if newValue {
                // Resume animation
                animationStartDate = Date()
            } else {
                // Pause animation and accumulate elapsed time
                if let startDate = animationStartDate {
                    let elapsedTime = Date().timeIntervalSince(startDate)
                    accumulatedTime += elapsedTime
                    animationStartDate = nil
                }
            }
        }
    }
}

#Preview {
    WavyBlobView(isAnimating: .constant(true) ,color: .purple)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black)
}
