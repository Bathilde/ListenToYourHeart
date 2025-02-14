//
//  CameraView.swift
//  ListenToYourHeart
//
//  Created by Bathilde Rocchia on 14/01/2025.
//

import SwiftUI

struct CameraView: View {
    @StateObject private var viewModel = CameraViewModel()
    
    var body: some View {
        VStack(spacing: 16) {
            if viewModel.isAuthorized {
                CameraPreviewView(session: viewModel.session)
                    .ignoresSafeArea()
                
                if let heartRate = viewModel.heartRate {
                    Text("Heart Rate: \(Int(heartRate)) BPM")
                        .font(.title2)
                        .padding()
                } else {
                    Text("Place your finger on the camera lens")
                        .padding()
                }
            } else {
                VStack(spacing: 20) {
                    Text("Authorize the camera to access this feature")
                        .multilineTextAlignment(.center)
                    
                    Button {
                        viewModel.startMonitoring()
                    } label: {
                        Text("Start monitoring")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(.white)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .padding(.horizontal, 32)
                    .background(Color.black.clipShape(RoundedRectangle(cornerRadius: 100)))
                }
                .padding()
            }
        }
    }
}
