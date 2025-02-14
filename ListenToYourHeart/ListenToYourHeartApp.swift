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
    var body: some Scene {
        WindowGroup {
            ContentView()
                .onAppear {
                    if WCSession.isSupported() {
                        let session = WCSession.default
                        session.activate()
                    }
                }
        }
    }
}
