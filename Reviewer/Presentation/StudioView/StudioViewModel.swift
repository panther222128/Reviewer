//
//  StudioViewModel.swift
//  Reviewer
//
//  Created by Horus on 4/10/24.
//

import Foundation
import AVFoundation
import Combine

// MARK: - Boilerplate
protocol StudioViewModel {
    var restaurantNamePublisher: AnyPublisher<String, Never> { get }
    var timeStringPublisher: AnyPublisher<String, Never> { get }
    
    func loadTitle()
    func setSession(on previewView: PreviewView)
    func integrateCaptureSession<T>(on previewView: PreviewView, preset: AVCaptureSession.Preset, delegate: T) where T: AVCapturePhotoOutputReadinessCoordinatorDelegate
    func capturePhoto(from previewView: PreviewView)
    func startSessionRunning()
    func stopSessionRunning()
    func suspendSessionQueue()
    func resumeSessionQueue()
    func didChangeCapture(mode: Studio.CaptureMode)
    func didRecord()
    func didChange(zoomFactor: Studio.SupportedZoomFactor)
    func didChangeResolution(frameRate: Studio.SupportedFrameRate, resolution: Studio.SupportedResolution, previewView: PreviewView)
    func didChange(frameRate: Studio.SupportedFrameRate, resolution: Studio.SupportedResolution, previewView: PreviewView)
    func focus(at devicePoint: CGPoint, monitorSubjectAreaChange: Bool)
    func didLoadTasteView(dishName: String)
    func runTimer()
    func cancelTimer()
    func resetTimer()
}

struct StudioViewModelActions {
    let showTasteListView: (_ restaurantId: String, _ restaurantName: String, _ dishName: String, _ thumbnailImageData: Data?) -> Void
}

final class DefaultStudioViewModel: StudioViewModel {

    private let actions: StudioViewModelActions
    private let studio: Studio
    private let useCase: StudioUseCase
    private let restaurantId: String
    private let restaurantName: String
    private let restaurantNameSubject: CurrentValueSubject<String, Never>
    private var timeString: String
    private let timeStringSubject: CurrentValueSubject<String, Never>
    private var date: Date
    private var timer: AnyCancellable
    
    var restaurantNamePublisher: AnyPublisher<String, Never> {
        return restaurantNameSubject.eraseToAnyPublisher()
    }
    var timeStringPublisher: AnyPublisher<String, Never> {
        return timeStringSubject.eraseToAnyPublisher()
    }
    
    init(studio: Studio, useCase: StudioUseCase, actions: StudioViewModelActions, id: String, restaurantName: String) {
        self.studio = studio
        self.useCase = useCase
        self.actions = actions
        self.restaurantId = id
        self.restaurantName = restaurantName
        self.restaurantNameSubject = .init("")
        self.date = Date()
        self.timeString = "00:00:00"
        self.timeStringSubject = .init("00:00:00")
        self.timer = .init({ })
    }
    
    func loadTitle() {
        restaurantNameSubject.send(restaurantName)
    }
    
    func setSession(on previewView: PreviewView) {
        studio.setSession(on: previewView)
    }
    
    func integrateCaptureSession<T>(on previewView: PreviewView, preset: AVCaptureSession.Preset, delegate: T) where T: AVCapturePhotoOutputReadinessCoordinatorDelegate {
        studio.integrateSession(on: previewView, preset: preset, delegate: delegate)
    }
    
    func capturePhoto(from previewView: PreviewView) {
        studio.capturePhoto(from: previewView)
    }
    
    func startSessionRunning() {
        studio.startSessionRunning()
    }
    
    func stopSessionRunning() {
        studio.stopSessionRunning()
    }
    
    func suspendSessionQueue() {
        studio.suspendSessionQueue()
    }
    
    func resumeSessionQueue() {
        studio.resumeSessionQueue()
    }
    
    func didChangeCapture(mode: Studio.CaptureMode) {
        studio.changeCapture(mode: mode)
    }
    
    func didRecord() {
        studio.captureMovie()
    }
    
    func didChange(zoomFactor: Studio.SupportedZoomFactor) {
        studio.change(zoomFactor: zoomFactor)
    }
    
    func didChangeResolution(frameRate: Studio.SupportedFrameRate, resolution: Studio.SupportedResolution, previewView: PreviewView) {
        studio.changeVideoQuality(frameRate: frameRate, resolution: resolution, previewView: previewView)
    }
    
    func didChange(frameRate: Studio.SupportedFrameRate, resolution: Studio.SupportedResolution, previewView: PreviewView) {
        studio.changeVideoQuality(frameRate: frameRate, resolution: resolution, previewView: previewView)
    }
    
    func focus(at devicePoint: CGPoint, monitorSubjectAreaChange: Bool) {
        studio.focus(at: devicePoint, monitorSubjectAreaChange: monitorSubjectAreaChange)
    }
    
    func runTimer() {
        date = Date()
        timer = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink(receiveValue: { [weak self] _ in
                guard let self = self else { return }
                
                let currentDate = Date()
                
                let date = self.date
                let elapsedTime = currentDate.timeIntervalSince(date)
                
                let hours = Int(elapsedTime) / 3600
                let minutes = Int(elapsedTime) / 60 % 60
                let seconds = Int(elapsedTime) % 60
                
                let timeString = String(format: "%02d:%02d:%02d", hours, minutes, seconds)
                
                self.timeStringSubject.send(timeString)
            })
    }
    
    func cancelTimer() {
        timer.cancel()
    }
    
    func resetTimer() {
        timeString = "00:00:00"
        timeStringSubject.send(timeString)
    }
    
    func didLoadTasteView(dishName: String) {
        let thumbnailImageData = studio.thumbnailData
        actions.showTasteListView(restaurantId, restaurantName, dishName, thumbnailImageData)
    }
    
}
