//
//  BreathingViewModel.swift
//  ListenToYourHeart
//
//  Created by Bathilde Rocchia on 14/01/2025.
//

import WatchConnectivity

class BreathingViewModel: ObservableObject {
    @Published var heartRate: Double?
    @Published var isAppleWatchConnected: Bool = false
    
    private let watchCommunicator: WatchCommunicator
    
    init(watchCommunicator: WatchCommunicator = .shared) {
        self.watchCommunicator = watchCommunicator
        self.watchCommunicator.delegate = self
    }
    
    func startAppleWatchHeartRateMonitoring() {
        watchCommunicator.startHeartRateMonitoring()
    }
    
    @MainActor
    func updateConnected(_ isAppleWatchConnected: Bool) {
        self.isAppleWatchConnected = isAppleWatchConnected
    }
    
    @MainActor
    func updateHeartRate(_ heartRate: Double) {
        self.heartRate = heartRate
    }
}

extension BreathingViewModel: WatchCommunicatorDelegate {
    func didReceiveHeartRate(_ heartRate: Double) {
        Task {
            await updateHeartRate(heartRate)
        }
    }
    
    func watchConnectionStatusChanged(_ isConnected: Bool) {
        Task {
            await updateConnected(isConnected)
        }
    }
}
