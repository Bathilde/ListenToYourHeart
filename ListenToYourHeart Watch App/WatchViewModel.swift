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
                DispatchQueue.main.async {
                    self.isAuthorized = true
                }
                monitor.startHeartRateMonitoring()
            } catch {
                print("Failed to get authorization: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self.isAuthorized = false
                }
            }
        }
    }
}

extension WatchViewModel: HeartRateMonitorDelegate {
    func didReceiveHeartRate(_ heartRate: Double) {
        self.heartRate = heartRate
    }
    
    func authorizationStatusChanged(_ isAuthorized: Bool) {
        DispatchQueue.main.async {
            self.isAuthorized = isAuthorized
        }
    }
}
