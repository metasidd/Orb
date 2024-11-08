//
//  OrbView.swift
//  Prototype-Orb
//
//  Created by Siddhant Mehta on 2024-11-06.
//
import SwiftUI

public struct OrbView: View {
    let configuration: OrbConfiguration

    private var glowColor: Color { configuration.glowColor }
    private var orbElementsSpeed: Double { configuration.speed }
    
    public init(configuration: OrbConfiguration = OrbConfiguration()) {
        self.configuration = configuration
    }

    public var body: some View {
        GeometryReader { geometry in
            let size = min(geometry.size.width, geometry.size.height)

            ZStack {
                // Base environment gradient background
                if configuration.showBackground {
                    background
                }

                // Outer glow effect - creates a soft halo
                BackgroundView(color: glowColor,
                               rotationSpeed: orbElementsSpeed * 0.75,
                               direction: .counterClockwise)
                    .padding(size * 0.03)
                    .blur(radius: size * 0.06)
                    .rotationEffect(.degrees(180))
                    .blendMode(.destinationOver)

                // Outer ring element - creates contrast
                BackgroundView(color: glowColor.opacity(0.5),
                               rotationSpeed: orbElementsSpeed * 0.25,
                               direction: .clockwise)
                    .frame(maxWidth: size * 0.94)
                    .rotationEffect(.degrees(180))
                    .padding(8)
                    .blur(radius: size * 0.032)

                // Organic movement elements
                if configuration.showWavyBlobs {
                    wavyBlob // Lower wavy blob
                    wavyBlobTwo // Upper wavy blob
                }

                if configuration.showGlowEffects {
                    // Core glow effects
                    ZStack {
                        // Primary core glow - fast rotation
                        BackgroundView(color: glowColor,
                                       rotationSpeed: orbElementsSpeed * 3,
                                       direction: .clockwise)
                            .blur(radius: size * 0.08)
                            .opacity(configuration.coreGlowIntensity)

                        // Secondary core glow - creates layered effect
                        BackgroundView(color: glowColor,
                                       rotationSpeed: orbElementsSpeed * 2.3,
                                       direction: .clockwise)
                            .blur(radius: size * 0.06)
                            .opacity(configuration.coreGlowIntensity)
                            .blendMode(.plusLighter)
                    }
                    .padding(size * 0.08)
                }

                // Floating particle effects
                if configuration.showParticles {
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
                    colors: configuration.showShadow ? configuration.backgroundColors : [.clear],
                    radius: size * 0.08
                )
            )
        }
    }

    var background: some View {
        LinearGradient(colors: configuration.backgroundColors,
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
                           rotationSpeed: orbElementsSpeed * 1.5,
                           direction: .clockwise)
                .mask {
                    WavyBlobView(color: .white, loopDuration: 60 / orbElementsSpeed * 1.75)
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
                           rotationSpeed: orbElementsSpeed * 0.75,
                           direction: .counterClockwise)
                .mask {
                    WavyBlobView(color: .white, loopDuration: 60 / orbElementsSpeed * 2.25)
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
