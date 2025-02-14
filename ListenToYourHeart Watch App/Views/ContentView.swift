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
        VStack(spacing: 0) {
            HeartbeatView()
            
            Spacer()
            
            HStack {
                Text("Monitored: ")
                    .font(.system(size: 16, weight: .medium))
                if let heartRate = viewModel.heartRate {
                    Text(heartRate.formatted())
                        .font(.system(size: 16, weight: .bold))
                }
            }
            .opacity(viewModel.heartRate == nil ? 0 : 1)
            .animation(.easeInOut, value: viewModel.heartRate)
            .frame(maxWidth: .infinity)
            
            Spacer()
            
            Button {
                viewModel.startMonitoring()
            } label: {
                Text("Start")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(.black)
            }
            .background(
                Color.white
                    .clipShape(RoundedRectangle(cornerRadius: 100))
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            )
        }
        .padding(.horizontal, 8)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
    }
}

#Preview {
    ContentView()
}
