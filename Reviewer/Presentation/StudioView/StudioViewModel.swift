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
    
    func loadTitle()
    func setSession(on previewView: PreviewView)
    func integrateCaptureSession<T>(on previewView: PreviewView, mode: Studio.CaptureMode, preset: AVCaptureSession.Preset, delegate: T) where T: AVCapturePhotoOutputReadinessCoordinatorDelegate
    func capturePhoto(from previewView: PreviewView)
    func startSessionRunning()
    func stopSessionRunning()
    func suspendSessionQueue()
    func resumeSessionQueue()
    func changeCapture(mode: Int)
    func didRecord()
    func didChangeZoomFactor(at number: Int)
    func didChangeResolution(at number: Int)
    func changeFrameRate(_ rate: Float64, width: Int32, height: Int32)
    func focus(at devicePoint: CGPoint, monitorSubjectAreaChange: Bool)
    func didLoadTasteView(with dishName: String)
}

struct StudioViewModelActions {
    let showTasteListView: (_ restaurantId: String, _ restaurantName: String, _ dishName: String) -> Void
}

final class DefaultStudioViewModel: StudioViewModel {

    private let actions: StudioViewModelActions
    private let studio: Studio
    private let useCase: StudioUseCase
    private let restaurantId: String
    private let restaurantName: String
    private let restaurantNameSubject: CurrentValueSubject<String, Never>
    
    var restaurantNamePublisher: AnyPublisher<String, Never> {
        return restaurantNameSubject.eraseToAnyPublisher()
    }
    
    init(studio: Studio, useCase: StudioUseCase, actions: StudioViewModelActions, id: String, restaurantName: String) {
        self.studio = studio
        self.useCase = useCase
        self.actions = actions
        self.restaurantId = id
        self.restaurantName = restaurantName
        self.restaurantNameSubject = .init("")
    }
    
    func loadTitle() {
        restaurantNameSubject.send(restaurantName)
    }
    
    func setSession(on previewView: PreviewView) {
        studio.setSession(on: previewView)
    }
    
    func integrateCaptureSession<T>(on previewView: PreviewView, mode: Studio.CaptureMode, preset: AVCaptureSession.Preset, delegate: T) where T: AVCapturePhotoOutputReadinessCoordinatorDelegate {
        studio.integrateSession(on: previewView, mode: mode, preset: preset, delegate: delegate)
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
    
    func changeCapture(mode: Int) {
        studio.changeCapture(mode: mode)
    }
    
    func didRecord() {
        studio.captureMovie()
    }
    
    func didChangeZoomFactor(at number: Int) {
        studio.changeZoomFactor(at: number)
    }
    
    func didChangeResolution(at number: Int) {
        studio.changeVideoResolution(at: number)
    }
    
    func changeFrameRate(_ rate: Float64, width: Int32, height: Int32) {
        studio.changeFrameRate(rate, width: width, height: height)
    }
    
    func focus(at devicePoint: CGPoint, monitorSubjectAreaChange: Bool) {
        studio.focus(at: devicePoint, monitorSubjectAreaChange: monitorSubjectAreaChange)
    }
    
    func didLoadTasteView(with dishName: String) {
        actions.showTasteListView(restaurantId, restaurantName, dishName)
    }
    
}
