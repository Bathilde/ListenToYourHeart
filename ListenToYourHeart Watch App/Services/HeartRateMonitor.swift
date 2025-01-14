//
//  HeartRateMonitor.swift
//  ListenToYourHeart
//
//  Created by Bathilde Rocchia on 14/01/2025.
//

import HealthKit
import WatchConnectivity

protocol HeartRateMonitorDelegate: AnyObject {
    func didReceiveHeartRate(_ heartRate: Double)
    func authorizationStatusChanged(_ isAuthorized: Bool)
}

class HeartRateMonitor: NSObject, WCSessionDelegate {
    private let healthStore = HKHealthStore()
    private var session: WCSession?
    private var heartRateQuery: HKQuery?
    var delegate: HeartRateMonitorDelegate? {
        didSet {
            notifyAuthorizationChanged()
        }
    }
    
    override init() {
        super.init()
        if WCSession.isSupported() {
            session = WCSession.default
            session?.delegate = self
            session?.activate()
        }
    }
    
    func isHealthKitAuthorized() -> Bool {
        let heartRateType = HKQuantityType.quantityType(forIdentifier: .heartRate)!
        let authorizationStatus = healthStore.authorizationStatus(for: heartRateType)
        
        switch authorizationStatus {
        case .sharingAuthorized:
            return true
        case .sharingDenied:
            print("HealthKit authorization denied")
            return false
        case .notDetermined:
            print("HealthKit authorization not determined")
            return false
        @unknown default:
            print("Unknown HealthKit authorization status")
            return false
        }
    }
    
    private func notifyAuthorizationChanged() {
        let isAuthorized = isHealthKitAuthorized()
        delegate?.authorizationStatusChanged(isAuthorized)
    }
    
    func requestAuthorization() async throws {
        let heartRateType = HKQuantityType.quantityType(forIdentifier: .heartRate)!
        let typesToRead: Set<HKSampleType> = [heartRateType]
        
        do {
            try await healthStore.requestAuthorization(toShare: [], read: typesToRead)
            print("HealthKit authorization granted")
            notifyAuthorizationChanged()
        } catch {
            print("HealthKit authorization failed: \(error.localizedDescription)")
            notifyAuthorizationChanged()
            throw error
        }
    }
    
    /// Starts heart rate monitoring
    func startHeartRateMonitoring() {
        let heartRateType = HKQuantityType.quantityType(forIdentifier: .heartRate)!
        
        let query = HKObserverQuery(sampleType: heartRateType, predicate: nil) { [weak self] query, completionHandler, error in
            guard error == nil else {
                print("Error observing heart rate: \(error!.localizedDescription)")
                return
            }
            
            self?.fetchLatestHeartRate()
            completionHandler()
        }
        
        healthStore.execute(query)
        heartRateQuery = query
    }
    
    private func fetchLatestHeartRate() {
        let heartRateType = HKQuantityType.quantityType(forIdentifier: .heartRate)!
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
        let query = HKSampleQuery(sampleType: heartRateType, predicate: nil, limit: 1, sortDescriptors: [sortDescriptor]) { [weak self] query, results, error in
            guard error == nil, let results = results as? [HKQuantitySample], let heartRateSample = results.first else {
                print("Error fetching heart rate: \(error?.localizedDescription ?? "No data")")
                return
            }
            
            let heartRate = heartRateSample.quantity.doubleValue(for: HKUnit(from: "count/min"))
            print("Latest Heart Rate: \(heartRate)")
            self?.sendHeartRateToiOS(heartRate)
        }
        
        healthStore.execute(query)
    }
    
    private func sendHeartRateToiOS(_ heartRate: Double) {
        guard let session = session, session.isReachable else {
            print("iOS device is not reachable")
            return
        }
        
        let message = ["heartRate": heartRate]
        session.sendMessage(message, replyHandler: nil) { error in
            print("Error sending heart rate to iOS: \(error.localizedDescription)")
        }
    }
    
    // WCSessionDelegate Methods
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        if let error = error {
            print("WCSession activation failed with error: \(error.localizedDescription)")
        }
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String: Any]) {
        if let action = message["action"] as? String, action == "startHeartRateMonitoring" {
            startHeartRateMonitoring()
        }
    }
}
