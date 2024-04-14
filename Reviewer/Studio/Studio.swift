//
//  Studio.swift
//  Reviewer
//
//  Created by Horus on 4/10/24.
//

import Foundation
import AVFoundation
import UIKit

final class Studio {

    private let sessionQueue: DispatchQueue
    private let captureSession: AVCaptureSession
    private var captureDevice: AVCaptureDevice?
    @objc dynamic var videoDeviceInput: AVCaptureDeviceInput?
    private var photoOutput: AVCapturePhotoOutput
    private var photoSettings: AVCapturePhotoSettings?
    private var photoOutputReadinessCoordinator: AVCapturePhotoOutputReadinessCoordinator?
    private var videoDeviceRotationCoordinator: AVCaptureDevice.RotationCoordinator?
    private var videoRotationAngleForHorizonLevelPreviewObservation: NSKeyValueObservation?
    private var inProgressPhotoCaptureDelegates: [Int64: PhotoCaptureProcessor]
    
    init() {
        self.sessionQueue = DispatchQueue(label: "session queue")
        self.captureSession = AVCaptureSession()
        self.captureDevice = nil
        self.videoDeviceInput = nil
        self.photoOutput = AVCapturePhotoOutput()
        self.photoSettings = nil
        self.photoOutputReadinessCoordinator = nil
        self.videoRotationAngleForHorizonLevelPreviewObservation = nil
        self.inProgressPhotoCaptureDelegates = [Int64: PhotoCaptureProcessor]()
    }
    
    func setSession(on previewView: PreviewView) {
        previewView.session = captureSession
    }
    
    func integrateSession<T>(on previewView: PreviewView, delegate: T) where T: AVCapturePhotoOutputReadinessCoordinatorDelegate {
        sessionQueue.async {
            self.setSession(preset: .photo)
            self.findCamera()
            self.addVideoDeviceInput(on: previewView)
            self.addPhotoOutput()
            self.setReadinessCoordinatorDelegate(delegate)
            self.configurePhotoOutput(with: .quality)
        }
    }
    
    func startSessionRunning() {
        sessionQueue.async {
            self.captureSession.startRunning()
        }
    }
    
    func suspendSessionQueue() {
        sessionQueue.suspend()
    }
    
    func resumeSessionQueue() {
        sessionQueue.resume()
    }
    
    func stopSessionRunning() {
        sessionQueue.async {
            self.captureSession.stopRunning()
            
            // MARK: - When capture session's output or input removed, connection also removed automatically.
            let inputs = self.captureSession.inputs
            inputs.forEach { self.captureSession.removeInput($0) }
            
            let outputs = self.captureSession.outputs
            outputs.forEach { self.captureSession.removeOutput($0) }
            
            self.captureDevice = nil
            self.videoDeviceInput = nil
            self.photoSettings = nil
            self.photoOutputReadinessCoordinator = nil
            self.videoDeviceRotationCoordinator = nil
            self.videoRotationAngleForHorizonLevelPreviewObservation = nil
        }
    }
    
    func capturePhoto(from previewView: PreviewView) {
        if let photoSettings = photoSettings {
            let photoSettings = AVCapturePhotoSettings(from: photoSettings)
            
            photoOutputReadinessCoordinator?.startTrackingCaptureRequest(using: photoSettings)
            
            if let videoDeviceRotationCoordinator = videoDeviceRotationCoordinator {
                sessionQueue.async {
                    if let photoOutputConnection = self.photoOutput.connection(with: .video) {
                        photoOutputConnection.videoRotationAngle = videoDeviceRotationCoordinator.videoRotationAngleForHorizonLevelCapture
                    } else {
                        print("Photo output connection is empty.")
                    }
                    let photoCaptureProcessor = PhotoCaptureProcessor(with: photoSettings) {
                        DispatchQueue.main.async {
                            previewView.videoPreviewLayer.opacity = 0
                            UIView.animate(withDuration: 0.25) {
                                previewView.videoPreviewLayer.opacity = 1
                            }
                        }
                    } completionHandler: { photoCaptureProcessor in
                        self.sessionQueue.async {
                            self.inProgressPhotoCaptureDelegates[photoCaptureProcessor.requestedPhotoSettings.uniqueID] = nil
                        }
                    }
                    self.inProgressPhotoCaptureDelegates[photoCaptureProcessor.requestedPhotoSettings.uniqueID] = photoCaptureProcessor
                    self.photoOutput.capturePhoto(with: photoSettings, delegate: photoCaptureProcessor)
                    if let photoOutputReadinessCoordinator = self.photoOutputReadinessCoordinator {
                        photoOutputReadinessCoordinator.stopTrackingCaptureRequest(using: photoSettings.uniqueID)
                    } else {
                        print("Photo out readiness coordinator is empty.")
                    }
                }
            } else {
                print("Video device rotation coordinator is empty.")
            }
            
        } else {
            print("No photo settings to capture.")
            return
        }
    }
    
    func setReadinessCoordinatorDelegate<T>(_ viewController: T) where T: AVCapturePhotoOutputReadinessCoordinatorDelegate {
        photoOutputReadinessCoordinator?.delegate = viewController
    }
    
    private func setSession(preset: AVCaptureSession.Preset) {
        captureSession.beginConfiguration()
        defer {
            captureSession.commitConfiguration()
        }
        captureSession.sessionPreset = preset
    }
    
    private func findCamera() {
        captureSession.beginConfiguration()
        defer {
            captureSession.commitConfiguration()
        }
        
        captureDevice = AVCaptureDevice.systemPreferredCamera
        guard let captureDevice = captureDevice else {
            print("Cannot find capture device.")
            captureSession.commitConfiguration()
            return
        }
    }
    
    private func addVideoDeviceInput(on previewView: PreviewView) {
        captureSession.beginConfiguration()
        defer {
            captureSession.commitConfiguration()
        }
        
        do {
            if let captureDevice = captureDevice {
                let videoDeviceInput = try AVCaptureDeviceInput(device: captureDevice)
                if captureSession.canAddInput(videoDeviceInput) {
                    // MARK: - If you want to manage input and output connection directly, you can use captureSession.addInputWithNoConnections() and captureSession.addOutputWithNoConnections()
                    captureSession.addInput(videoDeviceInput)
                    self.videoDeviceInput = videoDeviceInput
                    DispatchQueue.main.async {
                        self.createDeviceRotationCoordinator(on: previewView)
                    }
                } else {
                    captureSession.commitConfiguration()
                    print("Cannot add video device input.")
                }
            } else {
                captureSession.commitConfiguration()
                print("Cannot find capture device.")
            }
        } catch {
            captureSession.commitConfiguration()
            print("Cannot initialize video device input.")
        }
    }
    
    private func addPhotoOutput() {
        captureSession.beginConfiguration()
        defer {
            captureSession.commitConfiguration()
        }
        
        // MARK - If capture session contains input and output, connection automatically created.
        if captureSession.canAddOutput(photoOutput) {
            captureSession.addOutput(photoOutput)
        } else {
            print("Cannot add photo output.")
            captureSession.commitConfiguration()
        }
    }
    
    private func configurePhotoOutput(with quality: AVCapturePhotoOutput.QualityPrioritization) {
        captureSession.beginConfiguration()
        defer {
            captureSession.commitConfiguration()
        }
        if let videoDeviceInput = videoDeviceInput {
            let supportedMaxPhotoDimensions = videoDeviceInput.device.activeFormat.supportedMaxPhotoDimensions
            let largestDimesnion = supportedMaxPhotoDimensions.last
            self.photoOutput.maxPhotoDimensions = largestDimesnion!
        } else {
            print("Video device input empty.")
            captureSession.commitConfiguration()
        }
        
        photoOutput.maxPhotoQualityPrioritization = .quality
        photoOutput.isResponsiveCaptureEnabled = photoOutput.isResponsiveCaptureSupported
        photoOutput.isFastCapturePrioritizationEnabled = photoOutput.isFastCapturePrioritizationSupported
        photoOutput.isAutoDeferredPhotoDeliveryEnabled = photoOutput.isAutoDeferredPhotoDeliverySupported
        
        let readinessCoordinator = AVCapturePhotoOutputReadinessCoordinator(photoOutput: photoOutput)
        
        let photoSettings = setUpPhotoSettings(with: quality)
        DispatchQueue.main.async {
            self.photoSettings = photoSettings
            self.photoOutputReadinessCoordinator = readinessCoordinator
        }
    }
    
    private func setUpPhotoSettings(with quality: AVCapturePhotoOutput.QualityPrioritization) -> AVCapturePhotoSettings {
        captureSession.beginConfiguration()
        defer {
            captureSession.commitConfiguration()
        }
        var photoSettings = AVCapturePhotoSettings()
        
        if self.photoOutput.availablePhotoCodecTypes.contains(AVVideoCodecType.hevc) {
            photoSettings = AVCapturePhotoSettings(format: [AVVideoCodecKey: AVVideoCodecType.hevc])
        } else {
            photoSettings = AVCapturePhotoSettings()
        }
        
        photoSettings.maxPhotoDimensions = self.photoOutput.maxPhotoDimensions
        if !photoSettings.availablePreviewPhotoPixelFormatTypes.isEmpty {
            photoSettings.previewPhotoFormat = [kCVPixelBufferPixelFormatTypeKey as String: photoSettings.__availablePreviewPhotoPixelFormatTypes.first!]
        }

        photoSettings.photoQualityPrioritization = quality

        return photoSettings
    }
    
    private func createDeviceRotationCoordinator(on previewView: PreviewView) {
        if let videoDeviceInput = self.videoDeviceInput {
            self.videoDeviceRotationCoordinator = AVCaptureDevice.RotationCoordinator(device: videoDeviceInput.device, previewLayer: previewView.videoPreviewLayer)
            if let videoDeviceRotationCoordinator = videoDeviceRotationCoordinator {
                previewView.videoPreviewLayer.connection?.videoRotationAngle = videoDeviceRotationCoordinator.videoRotationAngleForHorizonLevelPreview
                
                self.videoRotationAngleForHorizonLevelPreviewObservation = videoDeviceRotationCoordinator.observe(\.videoRotationAngleForHorizonLevelPreview, options: .new) { _, change in
                    guard let videoRotationAngleForHorizonLevelPreview = change.newValue else { return }
                    
                    previewView.videoPreviewLayer.connection?.videoRotationAngle = videoRotationAngleForHorizonLevelPreview
                }
            } else {
                print("Cannot instantiate video device rotation coordinator.")
            }
        } else {
            print("Video device input empty.")
        }
    }
    
}
