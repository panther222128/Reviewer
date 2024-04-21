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
    
    private var _supportedInterfaceOrientations: UIInterfaceOrientationMask = .all
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        get { return _supportedInterfaceOrientations }
        set { _supportedInterfaceOrientations = newValue }
    }
    
    private var setupResult: SessionSetupResult = .success
    
    private let captureButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Capture", for: .normal)
        button.setTitleColor(.black, for: .normal)
        return button
    }()
    
    private let recordButton: RecordButton = {
        let button = RecordButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let previewView: PreviewView = {
        let previewView = PreviewView()
        previewView.translatesAutoresizingMaskIntoConstraints = false
        return previewView
    }()
    
    private let captureModeSegmentationControl: UISegmentedControl = {
        let segmentedControl = UISegmentedControl()
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        let symbolConfiguration = UIImage.SymbolConfiguration(pointSize: 36, weight: .bold, scale: .default)
        let cameraImage = UIImage(systemName: "camera", withConfiguration: symbolConfiguration)
        let movieClapperImage = UIImage(systemName: "movieclapper", withConfiguration: symbolConfiguration)
        segmentedControl.insertSegment(with: cameraImage, at: 0, animated: true)
        segmentedControl.insertSegment(with: movieClapperImage, at: 1, animated: true)
        segmentedControl.selectedSegmentIndex = 0
        return segmentedControl
    }()
    
    private var isRecord: Bool = false
    
    private var viewModel: StudioViewModel!
    
    private var cancellables: Set<AnyCancellable> = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        
        checkAuthorizationStatus()
        
        addSubviews()
        adjustLayoutOf(previewView: previewView)
        adjustLayoutOf(captureButton: captureButton)
        addActionOf(captureButton: captureButton)
        adjustLayoutOf(captureModeSegmentationControl: captureModeSegmentationControl)
        adjustLayoutOf(recordButton: recordButton)
        addActionOf(recordButton: recordButton)
        addCaptureModeSegmentedControlTarget()
        
        addFocusGesture()
        
        recordButton.isHidden = true
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
                self?.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
                self?.title = name
            }
            .store(in: &cancellables)
    }
    
    private func addCaptureModeSegmentedControlTarget() {
        captureModeSegmentationControl.addTarget(self, action: #selector(didSelectCaptureMode), for: .valueChanged)
    }
    
    @objc private func didSelectCaptureMode(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            captureButton.isHidden = false
            recordButton.isHidden = true
            viewModel.changeCapture(mode: sender.selectedSegmentIndex)
            
        case 1:
            captureButton.isHidden = true
            recordButton.isHidden = false
            viewModel.changeCapture(mode: sender.selectedSegmentIndex)
            
        default:
            break
            
        }
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
    
    private func addFocusGesture() {
        let gesture = UITapGestureRecognizer(target: self, action: #selector(focusOn))
        previewView.addGestureRecognizer(gesture)
    }
    
    @objc private func focusOn(_ gestureRecognizer: UITapGestureRecognizer) {
        let devicePoint = previewView.videoPreviewLayer.captureDevicePointConverted(fromLayerPoint: gestureRecognizer.location(in: gestureRecognizer.view))
        focus(at: devicePoint, monitorSubjectAreaChange: true)
    }
    
    private func focus(at devicePoint: CGPoint, monitorSubjectAreaChange: Bool) {
        viewModel.focus(at: devicePoint, monitorSubjectAreaChange: monitorSubjectAreaChange)
    }
    
}

extension StudioViewController {
    private func addSubviews() {
        view.addSubview(previewView)
        view.addSubview(captureButton)
        view.addSubview(recordButton)
        previewView.addSubview(captureModeSegmentationControl)
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
    
    private func adjustLayoutOf(recordButton: RecordButton) {
        recordButton.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        recordButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -60).isActive = true
    }
    
    private func adjustLayoutOf(captureModeSegmentationControl: UISegmentedControl) {
        captureModeSegmentationControl.bottomAnchor.constraint(equalTo: previewView.safeAreaLayoutGuide.bottomAnchor).isActive = true
        captureModeSegmentationControl.centerXAnchor.constraint(equalTo: previewView.centerXAnchor).isActive = true
    }
    
    private func addActionOf(captureButton: UIButton) {
        let action = UIAction { action in
            self.viewModel.capturePhoto(from: self.previewView)
            self.presentDishNameTextFieldAlert()
        }
        captureButton.addAction(action, for: .touchUpInside)
    }
    
    private func addActionOf(recordButton: RecordButton) {
        if let window = self.view.window, let windowScene = window.windowScene {
            switch windowScene.interfaceOrientation {
            case .portrait: self.supportedInterfaceOrientations = .portrait
            case .landscapeLeft: self.supportedInterfaceOrientations = .landscapeLeft
            case .landscapeRight: self.supportedInterfaceOrientations = .landscapeRight
            case .portraitUpsideDown: self.supportedInterfaceOrientations = .portraitUpsideDown
            case .unknown: self.supportedInterfaceOrientations = .portrait
            default: self.supportedInterfaceOrientations = .portrait
            }
        }
        self.setNeedsUpdateOfSupportedInterfaceOrientations()
        
        let action = UIAction { _ in
            if !self.isRecord {
                self.isRecord.toggle()
                recordButton.toggle()
                self.viewModel.didRecord()
            } else {
                self.isRecord.toggle()
                recordButton.toggle()
                self.viewModel.didRecord()
                self.presentDishNameTextFieldAlert()
            }
        }
        recordButton.addAction(action, for: .touchUpInside)
    }
    
    private func presentDishNameTextFieldAlert() {
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
}

extension StudioViewController: AVCapturePhotoOutputReadinessCoordinatorDelegate {
    func readinessCoordinator(_ coordinator: AVCapturePhotoOutputReadinessCoordinator, captureReadinessDidChange captureReadiness: AVCapturePhotoOutput.CaptureReadiness) {
        captureButton.isUserInteractionEnabled = (captureReadiness == .ready) ? true: false
    }
}
