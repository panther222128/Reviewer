//
//  StudioViewController.swift
//  Reviewer
//
//  Created by Horus on 4/10/24.
//

import UIKit
import AVFoundation
import Combine

final class StudioViewController: UIViewController {
    
    private enum SessionSetupResult {
        case success
        case notAuthorized
        case configurationFailed
    }
    
    private var setupResult: SessionSetupResult = .success
    
    private let captureButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Capture", for: .normal)
        button.setTitleColor(.black, for: .normal)
        return button
    }()
    
    private let previewView: PreviewView = {
        let previewView = PreviewView()
        previewView.translatesAutoresizingMaskIntoConstraints = false
        return previewView
    }()
    
    private var viewModel: StudioViewModel!
    
    private var cancellables: Set<AnyCancellable> = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        checkAuthorizationStatus()
        
        addSubviews()
        adjustLayoutOf(previewView: previewView)
        adjustLayoutOf(captureButton: captureButton)
        addActionOf(captureButton: captureButton)
        
        tabBarController?.tabBar.isHidden = true
        
        subscribe(restaurantNamePublisher: viewModel.restaurantNamePublisher)
        
        viewModel.loadTitle()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.setSession(on: previewView)
        viewModel.integrateCaptureSession(on: previewView, delegate: self)
        viewModel.startSessionRunning()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        viewModel.stopSessionRunning()
    }
    
    static func create(with viewModel: StudioViewModel) -> StudioViewController {
        let viewController = StudioViewController()
        viewController.viewModel = viewModel
        return viewController
    }
    
    private func subscribe(restaurantNamePublisher: AnyPublisher<String, Never>) {
        restaurantNamePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] name in
                self?.title = name
            }
            .store(in: &cancellables)
    }
    
    private func checkAuthorizationStatus() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            break
            
        case .notDetermined:
            viewModel.suspendSessionQueue()
            AVCaptureDevice.requestAccess(for: .video) { granted in
                if !granted {
                    self.setupResult = .notAuthorized
                }
                self.viewModel.resumeSessionQueue()
            }
            
        default:
            setupResult = .notAuthorized
            
        }
    }
    
}

extension StudioViewController {
    private func addSubviews() {
        view.addSubview(previewView)
        view.addSubview(captureButton)
    }
    
    private func adjustLayoutOf(previewView: PreviewView) {
        previewView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        previewView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        previewView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        previewView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    }
    
    private func adjustLayoutOf(captureButton: UIButton) {
        captureButton.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        captureButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40).isActive = true
    }
    
    private func addActionOf(captureButton: UIButton) {
        let action = UIAction { action in
            self.viewModel.capturePhoto(from: self.previewView)
            let alertController = UIAlertController(title: "음식 이름", message: nil, preferredStyle: .alert)
            alertController.addTextField()
            
            let confirmAction = UIAlertAction(title: "확인", style: .default) { _ in
                if let textFields = alertController.textFields {
                    if let textField = textFields.first {
                        if let text = textField.text, !text.isEmpty {
                            self.viewModel.didLoadTasteView(with: text)
                        } else {
                            print("Text must not be empty.")
                        }
                    } else {
                        print("Cannot find text field.")
                    }
                }
            }
            alertController.addAction(confirmAction)
            
            let cancelAction = UIAlertAction(title: "취소", style: .cancel, handler: nil)
            
            alertController.addAction(cancelAction)
            
            self.present(alertController, animated: true, completion: nil)
        }
        captureButton.addAction(action, for: .touchUpInside)
    }
}

extension StudioViewController: AVCapturePhotoOutputReadinessCoordinatorDelegate {
    func readinessCoordinator(_ coordinator: AVCapturePhotoOutputReadinessCoordinator, captureReadinessDidChange captureReadiness: AVCapturePhotoOutput.CaptureReadiness) {
        captureButton.isUserInteractionEnabled = (captureReadiness == .ready) ? true: false
    }
}
