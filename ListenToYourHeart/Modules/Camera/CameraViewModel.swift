//
//  CameraViewModel.swift
//  ListenToYourHeart
//
//  Created by Bathilde Rocchia on 14/01/2025.
//

import AVFoundation
import SwiftUI

class CameraViewModel: ObservableObject {
    @Published var isAuthorized = false
    @Published var session = AVCaptureSession()
    @Published var heartRate: Double?
    
    private let heartRateDetector = HeartRateByCamera()
    
    init() {
        heartRateDetector.delegate = self
        checkPermission()
    }
    
    func checkPermission() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            isAuthorized = true
            setupCamera()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                DispatchQueue.main.async {
                    self?.isAuthorized = granted
                    if granted {
                        self?.setupCamera()
                    }
                }
            }
        case .denied, .restricted:
            isAuthorized = false
        @unknown default:
            isAuthorized = false
        }
    }
    
    private func setupCamera() {
        Task {
            guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front) else {
                print("Failed to get camera device")
                return
            }
            
            do {
                let input = try AVCaptureDeviceInput(device: device)
                if session.canAddInput(input) {
                    session.addInput(input)
                }
                
                if device.hasTorch {
                    try device.lockForConfiguration()
                    device.torchMode = .on
                    device.unlockForConfiguration()
                }
                
                heartRateDetector.configureCaptureSession(session)
                
                session.startRunning()
            } catch {
                print("Failed to setup camera: \(error.localizedDescription)")
            }
        }
    }
    
    func startMonitoring() {
        if !isAuthorized {
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
