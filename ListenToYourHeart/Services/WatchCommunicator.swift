import WatchConnectivity

protocol WatchCommunicatorDelegate: AnyObject {
    func didReceiveHeartRate(_ heartRate: Double)
    func watchConnectionStatusChanged(_ isConnected: Bool)
}

class WatchCommunicator: NSObject, WCSessionDelegate {
    static let shared = WatchCommunicator()
    
    weak var delegate: WatchCommunicatorDelegate?
    private var session: WCSession?
    
    private override init() {
        super.init()
        setupSession()
    }
    
    private func setupSession() {
        if WCSession.isSupported() {
            session = WCSession.default
            session?.delegate = self
            session?.activate()
        }
    }
    
    func startHeartRateMonitoring() {
        guard let session = session else {
            delegate?.watchConnectionStatusChanged(false)
            print("Apple Watch is not reachable")
            return
        }
        
        delegate?.watchConnectionStatusChanged(true)
        let message = ["action": "startHeartRateMonitoring"]
        session.sendMessage(message, replyHandler: nil) { error in
            print("Error sending message to Apple Watch: \(error.localizedDescription)")
        }
    }
    
    // MARK: - WCSessionDelegate Methods
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        if let error = error {
            print("WCSession activation failed with error: \(error.localizedDescription)")
        }
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String: Any]) {
        if let heartRate = message["heartRate"] as? Double {
            DispatchQueue.main.async { [weak self] in
                self?.delegate?.didReceiveHeartRate(heartRate)
            }
            print("Received heart rate: \(heartRate)")
        }
    }
    
    func sessionDidBecomeInactive(_ session: WCSession) { }
    func sessionDidDeactivate(_ session: WCSession) { }
}
