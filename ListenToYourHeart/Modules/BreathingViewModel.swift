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
}

extension BreathingViewModel: WatchCommunicatorDelegate {
    func didReceiveHeartRate(_ heartRate: Double) {
        self.heartRate = heartRate
    }
    
    func watchConnectionStatusChanged(_ isConnected: Bool) {
        self.isAppleWatchConnected = isConnected
    }
}
