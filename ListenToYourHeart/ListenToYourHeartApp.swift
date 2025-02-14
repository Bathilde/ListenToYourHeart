//
//  ListenToYourHeartApp.swift
//  ListenToYourHeart
//
//  Created by Bathilde Rocchia on 14/01/2025.
//

import SwiftUI
import WatchConnectivity

@main
struct ListenToYourHeartApp: App {
    let viewModel = BreathingViewModel()
    let cameraViewModel = CameraViewModel()

    var body: some Scene {
        WindowGroup {
            ContentView(viewModel: viewModel, cameraViewModel: cameraViewModel)
                .onAppear {
                    if WCSession.isSupported() {
                        let session = WCSession.default
                        session.activate()
                    }
                }
        }
    }
}
