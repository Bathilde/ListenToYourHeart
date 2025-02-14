//
//  CameraManager.swift
//  ListenToYourHeart
//
//  Created by Bathilde Rocchia on 14/02/2025.
//

import SwiftUI
import AVFoundation

@Observable
class CameraManager {
    enum Status {
        case unconfigured
        case configured
        case unauthorized
        case failed
    }
    
    var captureSession: AVCaptureSession

    private(set) var status = Status.unconfigured
    private let videoOutput: AVCaptureVideoDataOutput
    private var camera: AVCaptureDevice?
    private let sessionQueue = DispatchQueue(label: "cameraManager.sessionQueue")

    init(captureSession: AVCaptureSession) {
        videoOutput = AVCaptureVideoDataOutput()
        self.captureSession = captureSession
    }

    func checkPermissions() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .notDetermined:
            sessionQueue.suspend()

            AVCaptureDevice.requestAccess(for: .video) { authorized in
                if !authorized {
                    self.status = .unauthorized
                }
                self.sessionQueue.resume()
            }
        case .restricted:
            status = .unauthorized
        case .denied:
            status = .unauthorized
        case .authorized:
            break
        @unknown default:
            status = .unauthorized
        }
    }

    func configure() {
        guard status == .unconfigured else {
            return
        }
        captureSession.beginConfiguration()
        defer {
            captureSession.commitConfiguration()
        }

        camera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back)
        guard let camera = camera,
              let cameraInput = try? AVCaptureDeviceInput(device: camera) else {
            status = .failed
            return
        }

        if captureSession.canAddInput(cameraInput) {
            captureSession.addInput(cameraInput)
        }

        if captureSession.canAddOutput(videoOutput) {
            captureSession.addOutput(videoOutput)
        }
    }

    func toggleTorch() {
        guard let camera = camera else { return }
        do {
            try camera.lockForConfiguration()
            if camera.hasTorch {
                try camera.setTorchModeOn(level: AVCaptureDevice.maxAvailableTorchLevel)
            }
            camera.unlockForConfiguration()
        } catch {
            print("Failed to configure camera: \(error)")
        }
    }

    func start() {
        guard status == .unconfigured else {
            return
        }
        sessionQueue.async {
            self.captureSession.startRunning()
        }
    }
}
