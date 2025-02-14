//
//  ContentView.swift
//  ListenToYourHeart
//
//  Created by Bathilde Rocchia on 14/01/2025.
//

import SwiftUI
import WatchConnectivity

struct ContentView: View {
    @State var viewModel: BreathingViewModel
    @State var cameraViewModel: CameraViewModel

    var body: some View {
        VStack(spacing: 32) {
            HeartbeatView()
                .padding(.top, 32)
            
            Spacer()
            
            if viewModel.isAppleWatchConnected {
                AppleWatchView(viewModel: $viewModel)
                    .padding(.bottom, 32)
            }
            
            CameraView(viewModel: $cameraViewModel)
                .padding(.bottom, 32)
        }
        .padding(32)
    }
}
