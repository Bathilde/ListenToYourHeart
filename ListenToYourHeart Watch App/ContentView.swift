//
//  ContentView.swift
//  ListenToYourHeart Watch App
//
//  Created by Bathilde Rocchia on 14/01/2025.
//

import SwiftUI

struct ContentView: View {
    @StateObject var viewModel = WatchViewModel()
    
    var body: some View {
        VStack(spacing: 32) {
            HeartbeatView()
                .padding(.top, 32)
            
            Spacer()
            
            if let heartRate = viewModel.heartRate {
                HStack {
                    Text("Monitored: ")
                    Text(heartRate.formatted())
                        .font(.system(size: 16, weight: .bold))
                }
            }
            
            Button {
                viewModel.startMonitoring()
            } label: {
                Text("-> Start monitoring")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(.black)
            }
            .padding(.bottom, 32)
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
