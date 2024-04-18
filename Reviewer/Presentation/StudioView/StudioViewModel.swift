//
//  StudioViewModel.swift
//  Reviewer
//
//  Created by Horus on 4/10/24.
//

import Foundation
import AVFoundation
import Combine

protocol StudioViewModel {
    var restaurantNamePublisher: AnyPublisher<String, Never> { get }
    
    func loadTitle()
    func setSession(on previewView: PreviewView)
    func integrateCaptureSession<T>(on previewView: PreviewView, delegate: T) where T: AVCapturePhotoOutputReadinessCoordinatorDelegate
    func capturePhoto(from previewView: PreviewView)
    func startSessionRunning()
    func stopSessionRunning()
    func suspendSessionQueue()
    func resumeSessionQueue()
    func didLoadTasteView(with dishName: String)
}

struct StudioViewModelActions {
    let showTasteListView: (String, String, String) -> Void
}

final class DefaultStudioViewModel: StudioViewModel {

    private let actions: StudioViewModelActions
    private let studio: Studio
    private let useCase: StudioUseCase
    private let restaurantName: String
    private let restaurantNameSubject: CurrentValueSubject<String, Never>
    private let restaurantId: String
    
    var restaurantNamePublisher: AnyPublisher<String, Never> {
        return restaurantNameSubject.eraseToAnyPublisher()
    }
    
    init(actions: StudioViewModelActions, studio: Studio, useCase: StudioUseCase, restaurantName: String, id: String) {
        self.actions = actions
        self.studio = studio
        self.useCase = useCase
        self.restaurantName = restaurantName
        self.restaurantNameSubject = .init("")
        self.restaurantId = id
    }
    
    func loadTitle() {
        restaurantNameSubject.send(restaurantName)
    }
    
    func setSession(on previewView: PreviewView) {
        studio.setSession(on: previewView)
    }
    
    func integrateCaptureSession<T>(on previewView: PreviewView, delegate: T) where T: AVCapturePhotoOutputReadinessCoordinatorDelegate {
        studio.integrateSession(on: previewView, delegate: delegate)
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
    
    func didLoadTasteView(with dishName: String) {
        actions.showTasteListView(dishName, restaurantName, restaurantId)
    }
    
}
