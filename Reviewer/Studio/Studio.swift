//
//  Studio.swift
//  Reviewer
//
//  Created by Horus on 4/10/24.
//

import Foundation
import AVFoundation
import UIKit
import Photos

final class Studio: NSObject {

    private let sessionQueue: DispatchQueue
    private let captureSession: AVCaptureSession
    private var videoCaptureDevice: AVCaptureDevice?
    private var audioCaptureDevice: AVCaptureDevice?
    @objc dynamic private var videoDeviceInput: AVCaptureDeviceInput?
    @objc dynamic private var audioDeviceInput: AVCaptureDeviceInput?
    private var photoOutput: AVCapturePhotoOutput
    private var audioDataOutput: AVCaptureAudioDataOutput?
    private var movieFileOutput: AVCaptureMovieFileOutput?
    private var photoSettings: AVCapturePhotoSettings?
    private var photoOutputReadinessCoordinator: AVCapturePhotoOutputReadinessCoordinator?
    private var videoDeviceRotationCoordinator: AVCaptureDevice.RotationCoordinator?
    private var videoRotationAngleForHorizonLevelPreviewObservation: NSKeyValueObservation?
    private var inProgressPhotoCaptureDelegates: [Int64: PhotoCaptureProcessor]
    private var backgroundRecordingID: UIBackgroundTaskIdentifier?
    
    enum CaptureMode: Int {
        case photo = 0
        case movie = 1
    }
    
    enum SupportedZoomFactor: CGFloat {
        case half = 0.5
        case one = 1
        case oneAndHalf = 1.5
        case two = 2.0
    }
    
    override init() {
        self.sessionQueue = DispatchQueue(label: "session queue")
        self.captureSession = AVCaptureSession()
        self.videoCaptureDevice = nil
        self.audioCaptureDevice = nil
        self.videoDeviceInput = nil
        self.audioDeviceInput = nil
        self.photoOutput = AVCapturePhotoOutput()
        self.audioDataOutput = nil
        self.movieFileOutput = nil
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
            
            self.videoCaptureDevice = nil
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
    
    func captureMovie() {
        if let videoDeviceRotationCoordinator = self.videoDeviceRotationCoordinator {
            let videoRotationAngle = videoDeviceRotationCoordinator.videoRotationAngleForHorizonLevelCapture
            
            sessionQueue.async {
                if let movieFileOutput = self.movieFileOutput {
                    if !movieFileOutput.isRecording {
                        if UIDevice.current.isMultitaskingSupported {
                            self.backgroundRecordingID = UIApplication.shared.beginBackgroundTask(expirationHandler: nil)
                        }
                        
                        let movieFileOutputConnection = movieFileOutput.connection(with: .video)
                        movieFileOutputConnection?.videoRotationAngle = videoRotationAngle
                        
                        let availableVideoCodecTypes = movieFileOutput.availableVideoCodecTypes
                        
                        if availableVideoCodecTypes.contains(.hevc) {
                            movieFileOutput.setOutputSettings([AVVideoCodecKey: AVVideoCodecType.hevc], for: movieFileOutputConnection!)
                        }
                        
                        let outputFileName = NSUUID().uuidString
                        let outputFilePath = (NSTemporaryDirectory() as NSString).appendingPathComponent((outputFileName as NSString).appendingPathExtension("mov")!)
                        movieFileOutput.startRecording(to: URL(fileURLWithPath: outputFilePath), recordingDelegate: self)
                    } else {
                        movieFileOutput.stopRecording()
                    }
                } else {
                    print("Not movie captureMode")
                }
            }
        }
    }
    
    func setReadinessCoordinatorDelegate<T>(_ viewController: T) where T: AVCapturePhotoOutputReadinessCoordinatorDelegate {
        photoOutputReadinessCoordinator?.delegate = viewController
    }
    
    func changeCapture(mode: Int) {
        if mode == CaptureMode.photo.rawValue {
            sessionQueue.async {
                self.captureSession.beginConfiguration()
                if let movieFileOutput = self.movieFileOutput {
                    self.captureSession.removeOutput(movieFileOutput)
                } else {
                    print("Capture session output problem.")
                }
                if let audioDataOutput = self.audioDataOutput {
                    self.captureSession.removeOutput(audioDataOutput)
                    self.audioDataOutput = nil
                } else {
                    print("Capture session output problem.")
                }
                
                if let audioDeviceInput = self.audioDeviceInput {
                    self.captureSession.removeInput(audioDeviceInput)
                    self.audioDeviceInput = nil
                } else {
                    print("Capture session input problem.")
                }
                
                self.audioCaptureDevice = nil

                self.captureSession.sessionPreset = .photo
                self.movieFileOutput = nil
                
                self.configurePhotoOutput(with: .quality)
                
                self.captureSession.commitConfiguration()
            }
        } else if mode == CaptureMode.movie.rawValue {
            sessionQueue.async {
                let movieFileOutput = AVCaptureMovieFileOutput()
                if self.captureSession.canAddOutput(movieFileOutput) {
                    self.captureSession.beginConfiguration()
                    self.captureSession.addOutput(movieFileOutput)
                    self.captureSession.sessionPreset = .high
                    
                    self.findMicrohone()
                    self.addAudioDeviceInput()
                    self.addAudioDataOutput()
                    
                    if let connection = movieFileOutput.connection(with: .video) {
                        if connection.isVideoMirroringSupported {
                            connection.preferredVideoStabilizationMode = .auto
                        }
                    }
                    self.captureSession.commitConfiguration()
                    self.movieFileOutput = movieFileOutput
                }
            }
        }
    }
    
    func changeZoomFactor(at number: Int) {
        sessionQueue.async {
            if let videoDeviceInput = self.videoDeviceInput {
                let device = videoDeviceInput.device
                do {
                    try device.lockForConfiguration()
                    
                    if number == 0 {
                        device.videoZoomFactor = 1.0
                    } else if number == 1 {
                        device.videoZoomFactor = 1.5
                    } else if number == 2 {
                        device.videoZoomFactor = 2.0
                    }

                    device.unlockForConfiguration()
                } catch {
                    print("Could not lock device for configuration.")
                }
            }
        }
    }
    
    func focus(at devicePoint: CGPoint, monitorSubjectAreaChange: Bool) {
        sessionQueue.async {
            if let videoDeviceInput = self.videoDeviceInput {
                let device = videoDeviceInput.device
                let focusMode: AVCaptureDevice.FocusMode = .autoFocus
                let exposureMode: AVCaptureDevice.ExposureMode = .autoExpose
                do {
                    try device.lockForConfiguration()
                    if device.isFocusPointOfInterestSupported && device.isFocusModeSupported(focusMode) {
                        device.focusPointOfInterest = devicePoint
                        device.focusMode = focusMode
                    }
                    
                    if device.isExposurePointOfInterestSupported && device.isExposureModeSupported(exposureMode) {
                        device.exposurePointOfInterest = devicePoint
                        device.exposureMode = exposureMode
                    }
                    
                    device.isSubjectAreaChangeMonitoringEnabled = monitorSubjectAreaChange
                    device.unlockForConfiguration()
                } catch {
                    print("Could not lock device for configuration.")
                }
            } else {
                
            }
        }
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
        
        videoCaptureDevice = AVCaptureDevice.systemPreferredCamera
        guard let captureDevice = videoCaptureDevice else {
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
            if let captureDevice = videoCaptureDevice {
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
    
    private func findMicrohone() {
        captureSession.beginConfiguration()
        defer {
            captureSession.commitConfiguration()
        }
        
        if let microphone = AVCaptureDevice.default(for: .audio) {
            audioCaptureDevice = microphone
        } else {
            print("Cannot find available microphone.")
            captureSession.commitConfiguration()
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
    
    private func addAudioDeviceInput() {
        captureSession.beginConfiguration()
        defer {
            captureSession.commitConfiguration()
        }
        
        do {
            if let audioCaptureDevice {
                let audioDeviceInput = try AVCaptureDeviceInput(device: audioCaptureDevice)
                if captureSession.canAddInput(audioDeviceInput) {
                    captureSession.addInput(audioDeviceInput)
                    self.audioDeviceInput = audioDeviceInput
                } else {
                    captureSession.commitConfiguration()
                    print("Cannot add audio device input.")
                }
            } else {
                captureSession.commitConfiguration()
                print("Cannot find audio capture device.")
            }
        } catch {
            captureSession.commitConfiguration()
            print("Cannot initialize audio device input.")
        }
    }
    
    private func addAudioDataOutput() {
        captureSession.beginConfiguration()
        defer {
            captureSession.commitConfiguration()
        }
        
        let audioDataOutput = AVCaptureAudioDataOutput()
        self.audioDataOutput = audioDataOutput
        
        if let output = self.audioDataOutput {
            if captureSession.canAddOutput(output) {
                captureSession.addOutput(output)
            } else {
                print("Cannot add audio data output.")
                captureSession.commitConfiguration()
            }
        } else {
            print("Cannot find audio data output.")
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

extension Studio: AVCaptureFileOutputRecordingDelegate {
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: (any Error)?) {
        func cleanup() {
            let path = outputFileURL.path
            if FileManager.default.fileExists(atPath: path) {
                do {
                    try FileManager.default.removeItem(atPath: path)
                } catch {
                    print("Could not remove file at url: \(outputFileURL)")
                }
            }
            
            if let currentBackgroundRecordingID = backgroundRecordingID {
                backgroundRecordingID = UIBackgroundTaskIdentifier.invalid
                
                if currentBackgroundRecordingID != UIBackgroundTaskIdentifier.invalid {
                    UIApplication.shared.endBackgroundTask(currentBackgroundRecordingID)
                }
            }
        }
        
        var success = true
        
        if error != nil {
            print("Movie file finishing error: \(String(describing: error))")
            success = (((error! as NSError).userInfo[AVErrorRecordingSuccessfullyFinishedKey] as AnyObject).boolValue)!
        }
        
        if success {
            PHPhotoLibrary.requestAuthorization { status in
                if status == .authorized {
                    PHPhotoLibrary.shared().performChanges({
                        let options = PHAssetResourceCreationOptions()
                        options.shouldMoveFile = true
                        let creationRequest = PHAssetCreationRequest.forAsset()
                        creationRequest.addResource(with: .video, fileURL: outputFileURL, options: options)
                    }, completionHandler: { success, error in
                        if !success {
                            print("AVCam couldn't save the movie to your photo library: \(String(describing: error))")
                        }
                        cleanup()
                    })
                } else {
                    cleanup()
                }
            }
        } else {
            cleanup()
        }
    }
    
    
}
