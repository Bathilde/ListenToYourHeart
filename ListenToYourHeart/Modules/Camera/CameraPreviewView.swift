//
//  CameraView.swift
//  ListenToYourHeart
//
//  Created by Bathilde Rocchia on 14/01/2025.
//

import UIKit
import SwiftUI
import AVFoundation
import CoreImage

final class AVCaptureVideoViewController: UIViewController {
    var previewLayer: AVCaptureVideoPreviewLayer?
    private weak var session: AVCaptureSession?

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        guard let session, previewLayer == nil else { return }
        previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer?.videoGravity = .resizeAspectFill
        previewLayer?.frame = self.view.frame
        if let previewLayer {
            self.view.layer.addSublayer(previewLayer)
        }
    }

    func setup(session: AVCaptureSession) {
        self.session = session
    }
}

struct CameraPreviewView: UIViewControllerRepresentable {
    var session: AVCaptureSession

    func makeUIViewController(context: Context) -> AVCaptureVideoViewController {
        let controller = AVCaptureVideoViewController()
        controller.setup(session: session)
        return controller
    }

    func updateUIViewController(_ uiViewController: AVCaptureVideoViewController, context: Context) { }
}
