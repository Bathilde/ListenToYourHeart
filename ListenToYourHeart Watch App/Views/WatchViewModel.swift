//
//  WatchViewModel.swift
//  ListenToYourHeart
//
//  Created by Bathilde Rocchia on 14/01/2025.
//

import SwiftUI

final class WatchViewModel: ObservableObject {
    @Published var heartRate: Double?
    @Published var isAuthorized: Bool = false
    
    private var monitor = HeartRateMonitor()
    
    init() {
        monitor.delegate = self
        isAuthorized = monitor.isHealthKitAuthorized()
    }
    
    func startMonitoring() {
        Task {
            do {
                try await monitor.requestAuthorization()
                await updateAuthorisation(true)
                monitor.startHeartRateMonitoring()
            } catch {
                print("Failed to get authorization: \(error.localizedDescription)")
                await updateAuthorisation(false)
            }
        }
    }
    
    @MainActor
    func updateAuthorisation(_ authorized: Bool) {
        self.isAuthorized = authorized
    }
    
    @MainActor
    func updateHeartRate(_ heartRate: Double) {
        self.heartRate = heartRate
    }
}

extension WatchViewModel: HeartRateMonitorDelegate {
    func didReceiveHeartRate(_ heartRate: Double) {
        Task {
            await updateHeartRate(heartRate)
        }
    }
    
    func authorizationStatusChanged(_ isAuthorized: Bool) {
        Task {
            await updateAuthorisation(true)
        }
    }
}
