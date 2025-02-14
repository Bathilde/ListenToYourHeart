//
//  ContentView.swift
//  ListenToYourHeart
//
//  Created by Bathilde Rocchia on 14/01/2025.
//

import SwiftUI
import WatchConnectivity

struct ContentView: View {
    @StateObject var viewModel = BreathingViewModel()
    
    var body: some View {
        VStack(spacing: 32) {
            HeartbeatView()
                .padding(.top, 32)
            
            Spacer()
            
            if WCSession.isSupported() {
                AppleWatchView(viewModel: viewModel)
                    .padding(.bottom, 32)
            } else {
                CameraView()
                    .padding(.bottom, 32)
            }
        }
        .padding(32)
    }
}

#Preview {
    ContentView()
}
