//
//  Particles.swift
//  Prototype-Orb
//
//  Created by Siddhant Mehta on 2024-11-06.
//
import SwiftUI
import SpriteKit

class ParticleScene: SKScene {
    let color: PlatformColor
    let speedRange: ClosedRange<Double>
    let sizeRange: ClosedRange<CGFloat>
    let particleCount: Int
    let opacityRange: ClosedRange<Double>
    
    init(
        size: CGSize,
        color: PlatformColor,
        speedRange: ClosedRange<Double>,
        sizeRange: ClosedRange<CGFloat>,
        particleCount: Int,
        opacityRange: ClosedRange<Double>
    ) {
        self.color = color
        self.speedRange = speedRange
        self.sizeRange = sizeRange
        self.particleCount = particleCount
        self.opacityRange = opacityRange
        super.init(size: size)
        
        backgroundColor = .clear
        setupParticleEmitter()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupParticleEmitter() {
        let emitter = SKEmitterNode()
        
        // Create a white particle texture
        emitter.particleTexture = createParticleTexture()
        
        // Update color properties
        emitter.particleColorSequence = nil
        emitter.particleColor = color
        emitter.particleColorBlendFactor = 1.0
        
        // Basic emitter properties
        emitter.particleSpeed = CGFloat(speedRange.lowerBound)
        emitter.particleSpeedRange = CGFloat(speedRange.upperBound - speedRange.lowerBound)
        emitter.particleScale = sizeRange.lowerBound
        emitter.particleScaleRange = sizeRange.upperBound - sizeRange.lowerBound
        
        // Alpha and fade properties
        emitter.particleAlpha = 0 // Start invisible
        emitter.particleAlphaSpeed = CGFloat(opacityRange.upperBound) / 0.5 // Fade in over 0.5 seconds
        emitter.particleAlphaRange = CGFloat(opacityRange.upperBound - opacityRange.lowerBound)
        
        // Create alpha sequence for fade in/out
        let alphaSequence = SKKeyframeSequence(keyframeValues: [
            0,                              // Start invisible
            Double.random(in: opacityRange),        // Fade in to max opacity
            Double.random(in: opacityRange),        // Stay at max opacity
            Double.random(in: opacityRange)         // Fade to min opacity
        ], times: [
            0,      // At start
            0.2,    // Reach max at 20% of lifetime
            0.8,    // Stay at max until 80% of lifetime
            1.0     // Fade to min by end
        ])
        emitter.particleAlphaSequence = alphaSequence
        
        // Create scale sequence for grow/shrink animation
        let scaleSequence = SKKeyframeSequence(keyframeValues: [
            sizeRange.lowerBound * 0.7,    // Start at half min size
            sizeRange.upperBound * 0.9,    // Grow to max size
            sizeRange.upperBound,          // Stay at max
            sizeRange.lowerBound * 0.8     // Shrink back to half min size
        ], times: [
            0,      // At start
            0.4,    // Reach max at 20% of lifetime
            0.7,    // Stay at max until 80% of lifetime
            1.0     // Shrink by end
        ])
        emitter.particleScaleSequence = scaleSequence
        
        emitter.particleBlendMode = .add
        
        // Center the emitter and set emission area to full size
        emitter.position = CGPoint(x: size.width/2, y: size.height/2)
        emitter.particlePositionRange = CGVector(dx: size.width, dy: size.height)
        
        // Particle birth and lifetime
        emitter.particleBirthRate = CGFloat(particleCount) / 2.0
        emitter.numParticlesToEmit = 0
        emitter.particleLifetime = 2.0
        emitter.particleLifetimeRange = 1.0
        
        // Update movement properties
        emitter.emissionAngle = CGFloat.pi / 2  // Point upwards (90 degrees)
        emitter.emissionAngleRange = CGFloat.pi / 6  // Allow 30 degree variation each way
        
        // Add some sideways drift
        emitter.xAcceleration = 0  // No horizontal acceleration
        emitter.yAcceleration = 20 // Slight upward acceleration
        
        addChild(emitter)
    }
    
    private func createParticleTexture() -> SKTexture {
        let size = CGSize(width: 8, height: 8)  // Smaller size for better performance

        #if os(macOS)
        // Hat tip: https://www.hackingwithswift.com/forums/macos/drawing-graphics-in-macos/23135

        let pixelsWide = Int(size.width)
        let pixelsHigh = Int(size.height)
        let bitmapBytesPerRow = pixelsWide * 4
        let bufferLength = pixelsHigh * bitmapBytesPerRow
        let bitmapData = CFDataCreateMutable(nil, 0)

        CFDataSetLength(bitmapData, CFIndex(bufferLength))

        let bitmap = CFDataGetMutableBytePtr(bitmapData)

        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)

        let context = CGContext(
            data: bitmap,
            width: pixelsWide,
            height: pixelsHigh,
            bitsPerComponent: 8,
            bytesPerRow: bitmapBytesPerRow,
            space: colorSpace,
            bitmapInfo: bitmapInfo.rawValue
        )

        context?.setFillColor(.white)
        let circlePath = NSBezierPath(ovalIn: CGRect(origin: .zero, size: size))
        circlePath.fill()

        context?.addPath(circlePath.cgPath)
        context?.drawPath(using: .fillStroke)

        let image = context?.makeImage()

        guard let image else {
            return SKTexture()
        }

        return SKTexture(cgImage: image)

        #else
        let renderer = UIGraphicsImageRenderer(size: size)
        
        let image = renderer.image { context in
            // Simple filled white circle
            UIColor.white.setFill()
            let circlePath = UIBezierPath(ovalIn: CGRect(origin: .zero, size: size))
            circlePath.fill()
        }
        
        return SKTexture(image: image)
        #endif
    }
}

struct ParticlesView: View {
    let color: Color
    let speedRange: ClosedRange<Double>
    let sizeRange: ClosedRange<CGFloat>
    let particleCount: Int
    let opacityRange: ClosedRange<Double>
    
    var scene: SKScene {
        let scene = ParticleScene(
            size: CGSize(width: 300, height: 300), // Use fixed size
            color: PlatformColor(color),
            speedRange: speedRange,
            sizeRange: sizeRange,
            particleCount: particleCount,
            opacityRange: opacityRange
        )
        scene.scaleMode = .aspectFit
        return scene
    }
    
    var body: some View {
        GeometryReader { geometry in
            SpriteView(scene: scene, options: [.allowsTransparency])
                .frame(width: geometry.size.width, height: geometry.size.height)
                .ignoresSafeArea()
        }
    }
}

#Preview {
    ParticlesView(
        color: .green,
        speedRange: 30...60,
        sizeRange: 0.2...1,
        particleCount: 100,
        opacityRange: 0.5...1
    )
    .background(.black)
}
