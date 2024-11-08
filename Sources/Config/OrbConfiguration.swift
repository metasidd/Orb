//
//  OrbConfiguration.swift
//  Orb
//
//  Created by Siddhant Mehta on 2024-11-08.
//

import SwiftUI

public struct OrbConfiguration {
    public let glowColor: Color
    public let backgroundColors: [Color]
    public let particleColor: Color
    
    public let showBackground: Bool
    public let showWavyBlobs: Bool
    public let showParticles: Bool
    public let showGlowEffects: Bool
    public let showShadow: Bool
    
    public let coreGlowIntensity: Double
    public let speed: Double
    
    internal init(
        backgroundColors: [Color],
        glowColor: Color,
        particleColor: Color,
        coreGlowIntensity: Double,
        showBackground: Bool,
        showWavyBlobs: Bool,
        showParticles: Bool,
        showGlowEffects: Bool,
        showShadow: Bool,
        speed: Double
    ) {
        self.backgroundColors = backgroundColors
        self.glowColor = glowColor
        self.particleColor = particleColor
        self.showBackground = showBackground
        self.showWavyBlobs = showWavyBlobs
        self.showParticles = showParticles
        self.showGlowEffects = showGlowEffects
        self.showShadow = showShadow
        self.coreGlowIntensity = coreGlowIntensity
        self.speed = speed
    }
    
    public init(
        backgroundColors: [Color] = [.green, .blue, .pink],
        glowColor: Color = .white,
        coreGlowIntensity: Double = 1.0,
        showBackground: Bool = true,
        showWavyBlobs: Bool = true,
        showParticles: Bool = true,
        showGlowEffects: Bool = true,
        showShadow: Bool = true,
        speed: Double = 60
    ) {
        self.init(
            backgroundColors: backgroundColors,
            glowColor: glowColor,
            particleColor: .white,
            coreGlowIntensity: coreGlowIntensity,
            showBackground: showBackground,
            showWavyBlobs: showWavyBlobs,
            showParticles: showParticles,
            showGlowEffects: showGlowEffects,
            showShadow: showShadow,
            speed: speed
        )
    }
}
