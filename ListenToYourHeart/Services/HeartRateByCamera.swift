//
//  HeartRateByCamera.swift
//  ListenToYourHeart
//
//  Created by Bathilde Rocchia on 14/01/2025.
//

import AVFoundation
import CoreImage

protocol HeartRateByCameraDelegate: AnyObject {
   @MainActor func heartRateUpdated(_ bpm: Double)
}

class HeartRateByCamera: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate {
    weak var delegate: HeartRateByCameraDelegate?
    private var measurements: [Double] = []
    private var lastSampleTime: Double = 0
    private var measurementStartTime: Double = 0
    
    private let requiredMeasurements = 300 
    private let measurementInterval: Double = 20
    private let validBpmRange = 45...180 
    
    func configureCaptureSession(_ session: AVCaptureSession) {
        let videoOutput = AVCaptureVideoDataOutput()
        videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "heartrate.camera.queue"))
        
        if session.canAddOutput(videoOutput) {
            session.addOutput(videoOutput)
        }
    }
    
    // MARK: - AVCaptureVideoDataOutputSampleBufferDelegate
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        let currentTime = CACurrentMediaTime()
        
        guard (currentTime - lastSampleTime) * 1000 >= measurementInterval else { return }
        lastSampleTime = currentTime
        
        if measurements.isEmpty {
            measurementStartTime = currentTime
        }
        
        guard let brightness = extractBrightnessFromFrame(sampleBuffer) else { return }
        measurements.append(brightness)
        
        if measurements.count >= requiredMeasurements {
            processMeasurements()
        }
    }
    
    private func extractBrightnessFromFrame(_ sampleBuffer: CMSampleBuffer) -> Double? {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return nil }
        
        let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
        let context = CIContext()
        let rect = CGRect(x: 0, y: 0, width: CVPixelBufferGetWidth(pixelBuffer),
                          height: CVPixelBufferGetHeight(pixelBuffer))
        
        guard let bitmap = context.createCGImage(ciImage, from: rect) else { return nil }
        
        return getAverageRedComponent(from: bitmap)
    }
    
    private func getAverageRedComponent(from image: CGImage) -> Double? {
        guard let data = CFDataGetBytePtr(image.dataProvider?.data) else { return nil }
        
        var totalRed = 0.0
        let bytesPerPixel = 4
        let pixelCount = image.width * image.height
        
        for i in stride(from: 0, to: pixelCount * bytesPerPixel, by: bytesPerPixel) {
            totalRed += Double(data[i])
        }
        
        return totalRed / Double(pixelCount)
    }
    
    private func processMeasurements() {
        // Apply bandpass filter (0.75-4.0 Hz, corresponding to 45-240 bpm)
        let filteredData = applyBandpassFilter(measurements)
        
        let frequencies = performFFT(filteredData)
        
        if let heartRate = findHeartRate(frequencies) {
            DispatchQueue.main.async {
                self.delegate?.heartRateUpdated(heartRate)
            }
        }
        
        measurements.removeAll()
    }
    
    private func applyBandpassFilter(_ data: [Double]) -> [Double] {
        let windowSize = 5
        var filtered = [Double]()
        
        for i in windowSize..<data.count - windowSize {
            let window = data[i-windowSize...i+windowSize]
            filtered.append(window.reduce(0, +) / Double(windowSize * 2 + 1))
        }
        
        return filtered
    }
    
    private func performFFT(_ data: [Double]) -> [(frequency: Double, magnitude: Double)] {
        var frequencies: [(frequency: Double, magnitude: Double)] = []
        let samplingRate = 1000.0 / measurementInterval  // Hz
        
        for i in 0..<data.count/2 {
            let frequency = Double(i) * samplingRate / Double(data.count)
            let magnitude = sqrt(pow(data[i], 2))
            frequencies.append((frequency, magnitude))
        }
        
        return frequencies
    }
    
    private func findHeartRate(_ frequencies: [(frequency: Double, magnitude: Double)]) -> Double? {
        let validFrequencies = frequencies.filter {
            let bpm = $0.frequency * 60
            return validBpmRange.contains(Int(bpm))
        }
        
        guard let maxFreq = validFrequencies.max(by: { $0.magnitude < $1.magnitude }) else {
            return nil
        }
        
        return maxFreq.frequency * 60
    }
}
