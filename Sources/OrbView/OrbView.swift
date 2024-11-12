//
//  OrbView.swift
//  Prototype-Orb
//
//  Created by Siddhant Mehta on 2024-11-06.
//
import SwiftUI

public struct OrbView: View {
    @Environment(\.scenePhase) var scenePhase
    @State private var isAnimating: Bool = true
    @State private var resumedFromBG = false

    private let config: OrbConfiguration
    
    public init(configuration: OrbConfiguration = OrbConfiguration()) {
        self.config = configuration
    }

    public var body: some View {
        GeometryReader { geometry in
            let size = min(geometry.size.width, geometry.size.height)

            ZStack {
                // Base gradient background layer
                if config.showBackground {
                    background
                }
                
                // Creates depth with rotating glow effects
                baseDepthGlows(size: size)

                // Adds organic movement with flowing blob shapes
                if config.showWavyBlobs {
                    wavyBlob
                    wavyBlobTwo
                }

                // Adds bright, energetic core glow animations
                if config.showGlowEffects {
                    coreGlowEffects(size: size)
                }

                // Overlays floating particle effects for additional dynamism
                if config.showParticles {
                    particleView
                        .frame(maxWidth: size, maxHeight: size)
                }
            }
            // Orb outline for depth
            .overlay {
                realisticInnerGlows
            }
            // Masking out all the effects so it forms a perfect circle
            .mask {
                Circle()
            }
            .aspectRatio(1, contentMode: .fit)
            // Adding realistic, layered shadows so its brighter near the core, and softer as it grows outwards
            .modifier(
                RealisticShadowModifier(
                    colors: config.showShadow ? config.backgroundColors : [.clear],
                    radius: size * 0.08
                )
            )
        }
        .onChange(of: scenePhase) { oldPhase, newPhase in
            if oldPhase == .background { resumedFromBG = true }

            switch newPhase {
            case .active:
                Task {
                    try await Task.sleep(nanoseconds: resumedFromBG ? 300_000_000 : 100_000_000)
                    if resumedFromBG { resumedFromBG = false }
                    isAnimating = true
                }
            case .background:
                isAnimating = false
            case .inactive:
                isAnimating = false
            @unknown default:
                break
            }
        }
    }

    private var background: some View {
        LinearGradient(colors: config.backgroundColors,
                       startPoint: .bottom,
                       endPoint: .top)
    }

    private var orbOutlineColor: LinearGradient {
        LinearGradient(colors: [.white, .clear],
                       startPoint: .bottom,
                       endPoint: .top)
    }
    
    private var particleView: some View {
        // Added multiple particle effects since the blurring amounts are different
        ZStack {
            ParticlesView(
                isAnimating: $isAnimating,
                color: config.particleColor,
                speedRange: 10...20,
                sizeRange: 0.5...1,
                particleCount: 10,
                opacityRange: 0...0.3
            )
            .blur(radius: 1)
            
            ParticlesView(
                isAnimating: $isAnimating,
                color: config.particleColor,
                speedRange: 20...30,
                sizeRange: 0.2...1,
                particleCount: 10,
                opacityRange: 0.3...0.8
            )
        }
        .blendMode(.plusLighter)
    }

    private var wavyBlob: some View {
        GeometryReader { geometry in
            let size = min(geometry.size.width, geometry.size.height)

            RotatingGlowView(
                isAnimating: $isAnimating,
                color: .white.opacity(0.75),
                rotationSpeed: config.speed * 1.5,
                direction: .clockwise
            )
            .mask {
                WavyBlobView(
                    isAnimating: $isAnimating,
                    color: .white,
                    loopDuration: 60 / config.speed * 1.75
                )
                .frame(maxWidth: size * 1.875)
                .offset(x: 0, y: size * 0.31)
            }
            .blur(radius: 1)
            .blendMode(.plusLighter)
        }
    }

    private var wavyBlobTwo: some View {
        GeometryReader { geometry in
            let size = min(geometry.size.width, geometry.size.height)

            RotatingGlowView(
                isAnimating: $isAnimating,
                color: .white,
                rotationSpeed: config.speed * 0.75,
                direction: .counterClockwise
            )
            .mask {
                WavyBlobView(
                    isAnimating: $isAnimating,
                    color: .white,
                    loopDuration: 60 / config.speed * 2.25
                )
                .frame(maxWidth: size * 1.25)
                .rotationEffect(.degrees(90))
                .offset(x: 0, y: size * -0.31)
            }
            .opacity(0.5)
            .blur(radius: 1)
            .blendMode(.plusLighter)
        }
    }

    private func coreGlowEffects(size: CGFloat) -> some View {
        ZStack {
            RotatingGlowView(
                isAnimating: $isAnimating,
                color: config.glowColor,
                rotationSpeed: config.speed * 3,
                direction: .clockwise
            )
            .blur(radius: size * 0.08)
            .opacity(config.coreGlowIntensity)

            RotatingGlowView(
                isAnimating: $isAnimating,
                color: config.glowColor,
                rotationSpeed: config.speed * 2.3,
                direction: .clockwise
            )
            .blur(radius: size * 0.06)
            .opacity(config.coreGlowIntensity)
            .blendMode(.plusLighter)
        }
        .padding(size * 0.08)
    }

    // New combined function replacing outerGlow and outerRing
    private func baseDepthGlows(size: CGFloat) -> some View {
        ZStack {
            // Outer glow (previously outerGlow function)
            RotatingGlowView(
                isAnimating: $isAnimating,
                color: config.glowColor,
                rotationSpeed: config.speed * 0.75,
                direction: .counterClockwise
            )
            .padding(size * 0.03)
            .blur(radius: size * 0.06)
            .rotationEffect(.degrees(180))
            .blendMode(.destinationOver)

            // Outer ring (previously outerRing function)
            RotatingGlowView(
                isAnimating: $isAnimating,
                color: config.glowColor.opacity(0.5),
                rotationSpeed: config.speed * 0.25,
                direction: .clockwise
            )
            .frame(maxWidth: size * 0.94)
            .rotationEffect(.degrees(180))
            .padding(8)
            .blur(radius: size * 0.032)
        }
    }

    private var realisticInnerGlows: some View {
        ZStack {
            // Outer stroke with heavy blur
            Circle()
                .stroke(orbOutlineColor, lineWidth: 8)
                .blur(radius: 32)
                .blendMode(.plusLighter)

            // Inner stroke with light blur
            Circle()
                .stroke(orbOutlineColor, lineWidth: 4)
                .blur(radius: 12)
                .blendMode(.plusLighter)
            
            Circle()
                .stroke(orbOutlineColor, lineWidth: 1)
                .blur(radius: 4)
                .blendMode(.plusLighter)
        }
        .padding(1)
    }
}

#Preview {
    let config = OrbConfiguration()
    OrbView(configuration: config)
        .aspectRatio(1, contentMode: .fit)
        .frame(maxWidth: 120)
}
