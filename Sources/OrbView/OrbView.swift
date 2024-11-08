//
//  OrbView.swift
//  Prototype-Orb
//
//  Created by Siddhant Mehta on 2024-11-06.
//
import SwiftUI

public struct OrbView: View {
    private let config: OrbConfiguration
    
    public init(configuration: OrbConfiguration = OrbConfiguration()) {
        self.config = configuration
    }

    public var body: some View {
        GeometryReader { geometry in
            let size = min(geometry.size.width, geometry.size.height)

            ZStack {
                // Base environment gradient background
                if config.showBackground {
                    background
                }

                // Outer glow effect - creates a soft halo
                BackgroundView(color: config.glowColor,
                               rotationSpeed: config.speed * 0.75,
                               direction: .counterClockwise)
                    .padding(size * 0.03)
                    .blur(radius: size * 0.06)
                    .rotationEffect(.degrees(180))
                    .blendMode(.destinationOver)

                // Outer ring element - creates contrast
                BackgroundView(color: config.glowColor.opacity(0.5),
                               rotationSpeed: config.speed * 0.25,
                               direction: .clockwise)
                    .frame(maxWidth: size * 0.94)
                    .rotationEffect(.degrees(180))
                    .padding(8)
                    .blur(radius: size * 0.032)

                // Organic movement elements
                if config.showWavyBlobs {
                    wavyBlob // Lower wavy blob
                    wavyBlobTwo // Upper wavy blob
                }

                if config.showGlowEffects {
                    // Core glow effects
                    ZStack {
                        // Primary core glow - fast rotation
                        BackgroundView(color: config.glowColor,
                                       rotationSpeed: config.speed * 3,
                                       direction: .clockwise)
                            .blur(radius: size * 0.08)
                            .opacity(config.coreGlowIntensity)

                        // Secondary core glow - creates layered effect
                        BackgroundView(color: config.glowColor,
                                       rotationSpeed: config.speed * 2.3,
                                       direction: .clockwise)
                            .blur(radius: size * 0.06)
                            .opacity(config.coreGlowIntensity)
                            .blendMode(.plusLighter)
                    }
                    .padding(size * 0.08)
                }

                // Floating particle effects
                if config.showParticles {
                    particleView
                        .frame(maxWidth: size, maxHeight: size)
                }
            }
            // Orb outline for depth
            .overlay {
                ZStack {
                    // Outer stroke with heavy blur
                    Circle()
                        .stroke(orbOutlineColor, lineWidth: 6)
                        .blur(radius: 12)

                    // Inner stroke with light blur
                    Circle()
                        .stroke(orbOutlineColor, lineWidth: 4)
                        .blur(radius: 8)
                        .blendMode(.plusLighter)
                }
                .padding(1)
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
    }

    var background: some View {
        LinearGradient(colors: config.backgroundColors,
                       startPoint: .bottom,
                       endPoint: .top)
    }

    var orbOutlineColor: LinearGradient {
        LinearGradient(colors: [.white, .clear],
                       startPoint: .bottom,
                       endPoint: .top)
    }
    
    var particleView: some View {
        // Added multiple particle effects since the blurring amounts are different
        ZStack {
            ParticlesView(
                color: .white,
                speedRange: 10...20,
                sizeRange: 0.5...1,
                particleCount: 10,
                opacityRange: 0...0.3
            )
            .blur(radius: 1)
            
            ParticlesView(
                color: .white,
                speedRange: 20...30,
                sizeRange: 0.2...1,
                particleCount: 10,
                opacityRange: 0.3...0.8
            )
        }
        .blendMode(.plusLighter)
    }

    var wavyBlob: some View {
        GeometryReader { geometry in
            let size = min(geometry.size.width, geometry.size.height)

            BackgroundView(color: .white.opacity(0.75),
                           rotationSpeed: config.speed * 1.5,
                           direction: .clockwise)
                .mask {
                    WavyBlobView(color: .white, loopDuration: 60 / config.speed * 1.75)
                        .frame(maxWidth: size * 1.875)
                        .offset(x: 0, y: size * 0.31)
                }
                .blur(radius: 1)
                .blendMode(.plusLighter)
        }
    }

    var wavyBlobTwo: some View {
        GeometryReader { geometry in
            let size = min(geometry.size.width, geometry.size.height)

            BackgroundView(color: .white,
                           rotationSpeed: config.speed * 0.75,
                           direction: .counterClockwise)
                .mask {
                    WavyBlobView(color: .white, loopDuration: 60 / config.speed * 2.25)
                        .frame(maxWidth: size * 1.25)
                        .rotationEffect(.degrees(90))
                        .offset(x: 0, y: size * -0.31)
                }
                .opacity(0.5)
                .blur(radius: 1)
                .blendMode(.plusLighter)
        }
    }
}

#Preview {
    let config = OrbConfiguration()
    OrbView(configuration: config)
        .aspectRatio(1, contentMode: .fit)
        .frame(maxWidth: 120)
}
