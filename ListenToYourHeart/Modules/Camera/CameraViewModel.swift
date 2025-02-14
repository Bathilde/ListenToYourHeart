//
//  CameraViewModel.swift
//  ListenToYourHeart
//
//  Created by Bathilde Rocchia on 14/01/2025.
//

import AVFoundation
import SwiftUI

@Observable
class CameraViewModel {
    enum Status {
        case started
        case authorized
        case denied
        case none
    }

    var status = Status.none
    let session = AVCaptureSession()
    var heartRate: Double?

    private let heartRateDetector = HeartRateByCamera()
    private let manager: CameraManager

    init() {
        manager = CameraManager(captureSession: session)
        heartRateDetector.delegate = self
    }

    @MainActor
    func checkPermission() {
        manager.checkPermissions()
        switch manager.status {
        case .configured:
            self.status = .authorized
        case .failed, .unauthorized:
            self.status = .denied
        case .unconfigured:
            self.status = .none
        }
    }

    @MainActor
    private func setAccessGranting(_ granted: Bool) {
        status = granted ? .authorized : .denied
        if granted {
            setupCamera()
        }
    }

    @MainActor
    func setupCamera() {
        manager.configure()
        heartRateDetector.configureCaptureSession(session)
        manager.start()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
            self.manager.toggleTorch()
        })
        status = .started
    }

    @MainActor
    func startMonitoring() {
        switch status {
        case .started:
            break // do nothing
        case .authorized:
            setupCamera()
        case .denied, .none:
            checkPermission()
        }
    }
}


extension CameraViewModel: HeartRateByCameraDelegate {
    func heartRateUpdated(_ bpm: Double) {
        DispatchQueue.main.async {
            self.heartRate = bpm
        }
    }
}
