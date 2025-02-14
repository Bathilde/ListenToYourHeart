//
//  AppleWatchView.swift
//  ListenToYourHeart
//
//  Created by Bathilde Rocchia on 14/01/2025.
//

import SwiftUI

struct AppleWatchView: View {
    @Binding var viewModel: BreathingViewModel
    
    var body: some View {
        VStack(spacing: 16) {
            if let heartRate = viewModel.heartRate {
                HStack {
                    Text("Monitored: ")
                    Text(heartRate.formatted())
                        .font(.system(size: 16, weight: .bold))
                }
            }
            
            Button {
                viewModel.startAppleWatchHeartRateMonitoring()
            } label: {
                Text("Start Monitoring (Apple Watch)")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(.white)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .padding(.horizontal, 32)
            .background(Color.black.clipShape(RoundedRectangle(cornerRadius: 100)))
        }
    }
}
