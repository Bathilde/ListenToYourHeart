//
//  HeartbeatView.swift
//  ListenToYourHeart
//
//  Created by Bathilde Rocchia on 14/01/2025.
//

import SwiftUI

struct HeartbeatView: View {
    @State private var isAnimating = false
    
    var body: some View {
        HStack(spacing: 8) {
            Text(Image(systemName: "heart.fill"))
                .font(.system(size: 44))
                .rotationEffect(.degrees(-30))
                .scaleEffect(isAnimating ? 1.2 : 1.0)
                .animation(
                    .easeInOut(duration: 0.5)
                    .repeatForever(autoreverses: true),
                    value: isAnimating
                )
                .onAppear {
                    isAnimating = true
                }
            Text("Listen To\nYou Heart")
                .font(.system(size: 32, weight: .bold))
        }
    }
}

@available(iOS 17.0, watchOS 10.0, *)
#Preview {
    HeartbeatView()
}
