//
//  StudioViewModel.swift
//  Reviewer
//
//  Created by Horus on 4/10/24.
//

import Foundation
import AVFoundation

protocol StudioViewModel {
    func setSession(on previewViwe: PreviewView)
    func integrateCaptureSession<T>(on previewView: PreviewView, delegate: T) where T: AVCapturePhotoOutputReadinessCoordinatorDelegate
    func capturePhoto(from previewView: PreviewView)
    func startSessionRunning()
    func stopSessionRunning()
    func suspendSessionQueue()
    func resumeSessionQueue()
    func didLoadTasteView(with dishName: String)
}

struct StudioViewModelActions {
    let showTasteListView: (Dish, String) -> Void
}

final class DefaultStudioViewModel: StudioViewModel {

    private let actions: StudioViewModelActions
    private let studio: Studio
    private let useCase: StudioUseCase
    private let restaurantName: String
    
    init(actions: StudioViewModelActions, studio: Studio, useCase: StudioUseCase, restaurantName: String) {
        self.actions = actions
        self.studio = studio
        self.useCase = useCase
        self.restaurantName = restaurantName
    }
    
    func setSession(on previewViwe: PreviewView) {
        studio.setSession(on: previewViwe)
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
        actions.showTasteListView(.init(id: UUID().uuidString, name: dishName, date: Date(), tastes: []), restaurantName)
    }
    
}
