//
//  BackgroundView.swift
//  Prototype-Orb
//
//  Created by Siddhant Mehta on 2024-11-06.
//

import SwiftUI

enum RotationDirection {
    case clockwise
    case counterClockwise

    var multiplier: Double {
        switch self {
        case .clockwise: return 1
        case .counterClockwise: return -1
        }
    }
}

struct RotatingGlowView: View {
    @Binding var isAnimating: Bool
    @State private var animationStartDate: Date?
    @State private var accumulatedRotation: Double = 0

    private let color: Color
    private let rotationSpeed: Double
    private let direction: RotationDirection

    init(
        isAnimating: Binding<Bool>,
        color: Color,
        rotationSpeed: Double = 30,
        direction: RotationDirection
    ) {
        self._isAnimating = isAnimating
        self.color = color
        self.rotationSpeed = rotationSpeed
        self.direction = direction
    }

    var body: some View {
        GeometryReader { geometry in
            let size = min(geometry.size.width, geometry.size.height)
            TimelineView(.animation) { timeline in
                let date = timeline.date

                // Encapsulate the computation in a closure
                let rotationAngle: Double = {
                    if let startDate = animationStartDate {
                        let elapsedTime = date.timeIntervalSince(startDate)
                        return accumulatedRotation + direction.multiplier * rotationSpeed * elapsedTime
                    } else {
                        return accumulatedRotation
                    }
                }()

                let rotationAngleAdjusted = rotationAngle.truncatingRemainder(dividingBy: 360)

                Circle()
                    .fill(color)
                    .mask {
                        ZStack {
                            Circle()
                                .frame(width: size, height: size)
                                .blur(radius: size * 0.16)
                            Circle()
                                .frame(width: size * 1.31, height: size * 1.31)
                                .offset(y: size * 0.31)
                                .blur(radius: size * 0.16)
                                .blendMode(.destinationOut)
                        }
                    }
                    .rotationEffect(.degrees(rotationAngleAdjusted))
            }
            .onAppear {
                if isAnimating {
                    animationStartDate = Date()
                }
            }
            .onChange(of: isAnimating) { newValue in
                if newValue {
                    animationStartDate = Date()
                } else {
                    if let startDate = animationStartDate {
                        let elapsedTime = Date().timeIntervalSince(startDate)
                        accumulatedRotation += direction.multiplier * rotationSpeed * elapsedTime
                        accumulatedRotation = accumulatedRotation.truncatingRemainder(dividingBy: 360)
                        animationStartDate = nil
                    }
                }
            }
        }
    }
}

#Preview {
    RotatingGlowView(
        isAnimating: .constant(true),
        color: .purple,
        rotationSpeed: 30,
        direction: .counterClockwise
    )
    .frame(width: 128, height: 128)
}
