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
    
    enum CaptureMode {
        case photo
        case movie
    }
    
    enum SupportedZoomFactor {
        case one
        case oneAndHalf
        case two
    }
    
    enum SupportedFrameRate {
        case thirty
        case sixty
    }
    
    enum SupportedResolution {
        case hd
        case hd4k
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
    
    func integrateSession<T>(on previewView: PreviewView, preset: AVCaptureSession.Preset, delegate: T) where T: AVCapturePhotoOutputReadinessCoordinatorDelegate {
        sessionQueue.async {
            self.setSession(preset: preset)
            self.findCamera()
            self.addVideoDeviceInput(on: previewView)
            self.setDeviceModes(focus: .continuousAutoFocus, exposure: .continuousAutoExposure)
            self.addPhotoOutput()
            self.setReadinessCoordinatorDelegate(delegate)
            self.configurePhotoOutput(with: .balanced)
        }
    }
    
    func changeCapture(mode: CaptureMode) {
        if mode == .photo {
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
                self.addPhotoOutput()
                self.configurePhotoOutput(with: .balanced)
                self.setDeviceModes(focus: .continuousAutoFocus, exposure: .continuousAutoExposure)
                self.captureSession.commitConfiguration()
            }
        } else if mode == .movie {
            sessionQueue.async {
                self.setDeviceModes(focus: .continuousAutoFocus, exposure: .continuousAutoExposure)
                self.addMovieFileOutput()
            }
        }
    }
    
    func changeVideoQuality(frameRate: SupportedFrameRate, resolution: SupportedResolution, previewView: PreviewView) {
        sessionQueue.async {
            self.findCamera()
            self.findMicrohone()
            self.addVideoDeviceInput(on: previewView)
            self.setDeviceModes(focus: .continuousAutoFocus, exposure: .continuousAutoExposure)
            self.addMovieFileOutput()
            
            if let videoCaptureDevice = self.videoCaptureDevice {
                self.captureSession.beginConfiguration()
                defer {
                    self.captureSession.commitConfiguration()
                }
                
                do {
                    try videoCaptureDevice.lockForConfiguration()
                    
                    var desiredFormat: AVCaptureDevice.Format?
                    
                    let formats = videoCaptureDevice.formats
                    
                    var targetWidth: Int = 1920
                    var targetHeight: Int = 1080
                    
                    switch resolution {
                    case .hd:
                        targetWidth = 1920
                        targetHeight = 1080
                        
                    case .hd4k:
                        targetWidth = 1920 * 2
                        targetHeight = 1080 * 2
                        
                    }
                    
                    for format in formats {
                        let description = format.formatDescription
                        
                        let dimensionWidth = description.dimensions.width
                        let dimensionHeight = description.dimensions.height
                        
                        if dimensionWidth != targetWidth || dimensionHeight != targetHeight {
                            continue
                        }
                        
                        let frameRates = format.videoSupportedFrameRateRanges
                        
                        switch frameRate {
                        case .thirty:
                            for range in frameRates {
                                if range.maxFrameRate >= 30 && range.minFrameRate <= 30 {
                                    desiredFormat = format
                                    break
                                }
                            }
                            
                        case .sixty:
                            for range in frameRates {
                                if range.maxFrameRate >= 60 && range.minFrameRate <= 60 {
                                    desiredFormat = format
                                    break
                                }
                            }
                        }
                    }
                    
                    guard let desiredFormat = desiredFormat else {
                        print("Cannot find desired format.")
                        return
                    }
                    videoCaptureDevice.activeFormat = desiredFormat
                    
                    switch frameRate {
                    case .thirty:
                        videoCaptureDevice.activeVideoMinFrameDuration = CMTime(value: 1, timescale: 30)
                        videoCaptureDevice.activeVideoMaxFrameDuration = CMTime(value: 1, timescale: 30)
                        
                    case .sixty:
                        videoCaptureDevice.activeVideoMinFrameDuration = CMTime(value: 1, timescale: 60)
                        videoCaptureDevice.activeVideoMaxFrameDuration = CMTime(value: 1, timescale: 60)
                        
                    }
                    
                    videoCaptureDevice.unlockForConfiguration()
                } catch {
                    print("Cannot lock device.")
                }
            } else {
                print("Cannot find video device.")
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
    
}

// MARK: - Action
extension Studio {
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
}

// MARK: - Device
extension Studio {
    private func findCamera() {
        captureSession.beginConfiguration()
        defer {
            captureSession.commitConfiguration()
        }
        
        videoCaptureDevice = AVCaptureDevice.default(for: .video)
        guard let captureDevice = videoCaptureDevice else {
            print("Cannot find capture device.")
            captureSession.commitConfiguration()
            return
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
}

// MARK: Input
extension Studio {
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
    
    private func addVideoDeviceInput(on previewView: PreviewView) {
        captureSession.beginConfiguration()
        defer {
            captureSession.commitConfiguration()
        }
        
        if let videoDeviceInput = self.videoDeviceInput {
            captureSession.removeInput(videoDeviceInput)
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
    
    private func setDeviceModes(focus: AVCaptureDevice.FocusMode, exposure: AVCaptureDevice.ExposureMode) {
        sessionQueue.async {
            self.captureSession.beginConfiguration()
            defer {
                self.captureSession.commitConfiguration()
            }
            if let videoDeviceInput = self.videoDeviceInput {
                let device = videoDeviceInput.device
                let focusMode: AVCaptureDevice.FocusMode = .continuousAutoFocus
                let exposureMode: AVCaptureDevice.ExposureMode = .continuousAutoExposure
                do {
                    try device.lockForConfiguration()
                    if device.isFocusPointOfInterestSupported && device.isFocusModeSupported(focusMode) {
                        device.focusMode = focusMode
                    }
                    
                    if device.isExposurePointOfInterestSupported && device.isExposureModeSupported(exposureMode) {
                        device.exposureMode = exposureMode
                    }
                    
                    device.unlockForConfiguration()
                } catch {
                    print("Could not lock device for configuration.")
                }
            }
        }
    }
}

// MAKK: - Output
extension Studio {
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
        
        photoOutput.maxPhotoQualityPrioritization = quality
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
    
    private func addPhotoOutput() {
        captureSession.beginConfiguration()
        defer {
            captureSession.commitConfiguration()
        }
        
        if let movieFileOutput = self.movieFileOutput {
            captureSession.removeOutput(movieFileOutput)
        }
        
        // MARK - If capture session contains input and output, connection automatically created.
        if captureSession.canAddOutput(photoOutput) {
            captureSession.addOutput(photoOutput)
        } else {
            print("Cannot add photo output.")
            captureSession.commitConfiguration()
        }
    }
    
    private func addMovieFileOutput() {
        let movieFileOutput = AVCaptureMovieFileOutput()
        if captureSession.canAddOutput(movieFileOutput) {
            captureSession.beginConfiguration()
            
            captureSession.removeOutput(photoOutput)
            
            captureSession.addOutput(movieFileOutput)
            captureSession.sessionPreset = .hd1920x1080
            
            findMicrohone()
            addAudioDeviceInput()
            addAudioDataOutput()
            
            if let connection = movieFileOutput.connection(with: .video) {
                if connection.isVideoMirroringSupported {
                    connection.preferredVideoStabilizationMode = .auto
                } else {
                    print("Movie connection dosen't support video mirroring")
                }
            } else {
                print("Movie connection is empty.")
            }
            captureSession.commitConfiguration()
            self.movieFileOutput = movieFileOutput
        }
    }
    
    func setReadinessCoordinatorDelegate<T>(_ viewController: T) where T: AVCapturePhotoOutputReadinessCoordinatorDelegate {
        photoOutputReadinessCoordinator?.delegate = viewController
    }
}

// MARK: - Run capture session
extension Studio {
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
}

// MARK: - Additional feature
extension Studio {
    func change(zoomFactor: SupportedZoomFactor) {
        sessionQueue.async {
            if let videoDeviceInput = self.videoDeviceInput {
                let device = videoDeviceInput.device
                do {
                    try device.lockForConfiguration()
                    
                    switch zoomFactor {
                    case .one:
                        device.videoZoomFactor = 1.0
                        
                    case .oneAndHalf:
                        device.videoZoomFactor = 1.5
                        
                    case .two:
                        device.videoZoomFactor = 2.0
                        
                    }
                    
                    device.unlockForConfiguration()
                } catch {
                    print("Could not lock device for configuration.")
                }
            } else {
                print("Video device input is empty.")
            }
        }
    }
    
    func changeVideoResolution(at number: Int) {
        sessionQueue.async {
            self.captureSession.beginConfiguration()
            defer {
                self.captureSession.commitConfiguration()
            }
            if number == 0 {
                self.captureSession.sessionPreset = .hd1920x1080
            } else if number == 1 {
                self.captureSession.sessionPreset = .hd4K3840x2160
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
                print("Video device input is empty.")
            }
        }
    }
}

// MARK: - Save movie
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
                } else {
                    print("Cannot find current background recording ID.")
                }
            } else {
                print("Background recording ID is empty.")
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

// MARK: - Rotation
extension Studio {
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

// MARK: - Photo settings
extension Studio {
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
}
