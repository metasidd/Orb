//
//  RealisticShadows.swift
//  Prototype-Orb
//
//  Created by Siddhant Mehta on 2024-11-06.
//
import SwiftUI

struct RealisticShadowModifier: ViewModifier {
    let colors: [Color]
    let radius: CGFloat

    func body(content: Content) -> some View {
        content
            .background {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: colors,
                            startPoint: .bottom,
                            endPoint: .top
                        )
                    )
                    .blur(radius: radius * 0.75)
                    .opacity(0.5)
                    .offset(y: radius * 0.5)
            }
            .background {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: colors,
                            startPoint: .bottom,
                            endPoint: .top
                        )
                    )
                    .blur(radius: radius * 3)
                    .opacity(0.3)
                    .offset(y: radius * 0.75)
            }
    }
}
