//
//  StudioUseCase.swift
//  Reviewer
//
//  Created by Horus on 4/10/24.
//

import Foundation
import AVFoundation

// MARK: - Boilerplate
protocol StudioUseCase {
    func setSession(on previewView: PreviewView)
    func integrateSession<T>(on previewView: PreviewView, preset: AVCaptureSession.Preset, delegate: T) where T: AVCapturePhotoOutputReadinessCoordinatorDelegate
    func capturePhoto(from previewView: PreviewView)
    func startSessionRunning()
    func stopSessionRunning()
    func suspendSessionQueue()
    func resumeSessionQueue()
}

final class DefaultStudioUseCase: StudioUseCase {
    
    private let studio: Studio
    
    init(studio: Studio) {
        self.studio = studio
    }
    
    func setSession(on previewView: PreviewView) {
        studio.setSession(on: previewView)
    }
    
    func integrateSession<T>(on previewView: PreviewView, preset: AVCaptureSession.Preset, delegate: T) where T: AVCapturePhotoOutputReadinessCoordinatorDelegate {
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
    
}
