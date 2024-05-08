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
    
    private enum MovieResolution {
        case hd
        case hd4k
    }
    
    private enum MovieFrameRate {
        case thirty
        case sixty
    }
    
    private var _supportedInterfaceOrientations: UIInterfaceOrientationMask = .all
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        get { return _supportedInterfaceOrientations }
        set { _supportedInterfaceOrientations = newValue }
    }
    
    private var setupResult: SessionSetupResult = .success
    
    private var portraitConstraints: [NSLayoutConstraint] = []
    private var landscapeConstraints: [NSLayoutConstraint] = []
    
    private var movieResolution: MovieResolution = .hd
    private var movieFrameRate: MovieFrameRate = .thirty
    
    private let captureButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        let symbolConfiguration = UIImage.SymbolConfiguration(pointSize: 64, weight: .light, scale: .default)
        let shutterImage = UIImage(systemName: "camera.shutter.button", withConfiguration: symbolConfiguration)
        button.setImage(shutterImage, for: .normal)
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
    
    private let captureModeSegmentedControl: UISegmentedControl = {
        let segmentedControl = UISegmentedControl()
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        let symbolConfiguration = UIImage.SymbolConfiguration(pointSize: 24, weight: .light, scale: .default)
        let cameraImage = UIImage(systemName: "camera", withConfiguration: symbolConfiguration)
        let movieClapperImage = UIImage(systemName: "movieclapper", withConfiguration: symbolConfiguration)
        segmentedControl.insertSegment(with: cameraImage, at: 0, animated: true)
        segmentedControl.insertSegment(with: movieClapperImage, at: 1, animated: true)
        segmentedControl.selectedSegmentIndex = 0
        return segmentedControl
    }()
    
    private let videoZoomFactorSegmentedControl: UISegmentedControl = {
        let segmentedControl = UISegmentedControl()
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        segmentedControl.insertSegment(withTitle: "1.0x", at: 0, animated: true)
        segmentedControl.insertSegment(withTitle: "1.5x", at: 1, animated: true)
        segmentedControl.insertSegment(withTitle: "2.0x", at: 2, animated: true)
        segmentedControl.selectedSegmentIndex = 0
        return segmentedControl
    }()
    
    private let frameRateSegmentedControl: UISegmentedControl = {
        let segmentedControl = UISegmentedControl()
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        segmentedControl.insertSegment(withTitle: "30", at: 0, animated: true)
        segmentedControl.insertSegment(withTitle: "60", at: 1, animated: true)
        segmentedControl.selectedSegmentIndex = 0
        return segmentedControl
    }()
    
    private let recordTimerLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .white
        return label
    }()
    
    private let movieResolutionSegmentedControl: UISegmentedControl = {
        let segmentedControl = UISegmentedControl()
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        segmentedControl.insertSegment(withTitle: "HD", at: 0, animated: true)
        segmentedControl.insertSegment(withTitle: "4K", at: 1, animated: true)
        segmentedControl.selectedSegmentIndex = 0
        return segmentedControl
    }()
    
    private var isRecord: Bool = false
    
    private var viewModel: StudioViewModel!
    
    private var cancellables: Set<AnyCancellable> = []
    
    override var shouldAutorotate: Bool {
        return !isRecord
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        
        checkAuthorizationStatus()
        
        addSubviews()
        adjustLayoutOf(previewView: previewView)
        adjustLayoutOf(captureButton: captureButton)
        addActionOf(captureButton: captureButton)
        adjustLayoutOf(videoZoomFactorSegmentedControl: videoZoomFactorSegmentedControl)
        adjustLayoutOf(movieResolutionSegmentedControl: movieResolutionSegmentedControl)
        adjustLayoutOf(frameRateSegmentedControl: frameRateSegmentedControl)
        adjustLayoutOf(captureModeSegmentedControl: captureModeSegmentedControl)
        adjustLayoutOf(recordButton: recordButton)
        adjustLandscapeLayoutOf(recordButton: recordButton)
        adjustLandscapeLayoutOf(captureButton: captureButton)
        adjustLandscapeLayoutOf(captureModeSegmentedControl: captureModeSegmentedControl)
        adjustLandscapeLayoutOf(videoZoomFactorSegmentedControl: videoZoomFactorSegmentedControl)
        addActionOf(recordButton: recordButton)
        adjustLayoutOf(recordingTimerLabel: recordTimerLabel)
        addZoomFactorSegmentedControlTarget()
        addMovieResolutionSegmentedControlTarget()
        addFrameRateSegmentedControlTarget()
        addCaptureModeSegmentedControlTarget()
        
        movieResolutionSegmentedControl.isHidden = true
        frameRateSegmentedControl.isHidden = true
        recordTimerLabel.isHidden = true
        
        addFocusGesture()
        
        recordButton.isHidden = true
        tabBarController?.tabBar.isHidden = true
        
        subscribe(restaurantNamePublisher: viewModel.restaurantNamePublisher)
        subscribe(timeStringPublisher: viewModel.timeStringPublisher)
        
        viewModel.loadTitle()
        
        NSLayoutConstraint.activate(portraitConstraints)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if captureModeSegmentedControl.selectedSegmentIndex == 0 {
            viewModel.setSession(on: previewView)
            viewModel.integrateCaptureSession(on: previewView, preset: .photo, delegate: self)
            viewModel.startSessionRunning()
        } else if captureModeSegmentedControl.selectedSegmentIndex == 1 {
            if movieResolution == .hd && movieFrameRate == .thirty {
                // 1080 30
                viewModel.setSession(on: previewView)
                viewModel.didChange(frameRate: .thirty, resolution: .hd, previewView: previewView)
                viewModel.startSessionRunning()
            } else if movieResolution == .hd && movieFrameRate == .sixty {
                // 1080 60
                viewModel.setSession(on: previewView)
                viewModel.didChange(frameRate: .sixty, resolution: .hd, previewView: previewView)
                viewModel.startSessionRunning()
            } else if movieResolution == .hd4k && movieFrameRate == .thirty {
                // 4k 30
                viewModel.setSession(on: previewView)
                viewModel.didChange(frameRate: .thirty, resolution: .hd4k, previewView: previewView)
                viewModel.startSessionRunning()
            } else if movieResolution == .hd4k && movieFrameRate == .sixty {
                // 4k 60
                viewModel.setSession(on: previewView)
                viewModel.didChange(frameRate: .sixty, resolution: .hd4k, previewView: previewView)
                viewModel.startSessionRunning()
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        viewModel.stopSessionRunning()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate { _ in
            
        } completion: { _ in
            if UIDevice.current.orientation.isPortrait {
                NSLayoutConstraint.activate(self.portraitConstraints)
                NSLayoutConstraint.deactivate(self.landscapeConstraints)
            } else if UIDevice.current.orientation.isLandscape {
                NSLayoutConstraint.activate(self.landscapeConstraints)
                NSLayoutConstraint.deactivate(self.portraitConstraints)
            }
        }

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
    
    private func subscribe(timeStringPublisher: AnyPublisher<String, Never>) {
        timeStringPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] time in
                self?.recordTimerLabel.text = time
            }
            .store(in: &cancellables)
    }
    
    private func addZoomFactorSegmentedControlTarget() {
        videoZoomFactorSegmentedControl.addTarget(self, action: #selector(didSelectZoomFactor), for: .valueChanged)
    }
    
    @objc private func didSelectZoomFactor(_ sender: UISegmentedControl) {
        let selected = sender.selectedSegmentIndex
        switch selected {
        case 0:
            viewModel.didChange(zoomFactor: .one)
            
        case 1:
            viewModel.didChange(zoomFactor: .oneAndHalf)
            
        case 2:
            viewModel.didChange(zoomFactor: .two)
            
        default:
            break
            
        }
    }
    
    private func addMovieResolutionSegmentedControlTarget() {
        movieResolutionSegmentedControl.addTarget(self, action: #selector(didSelectResolution), for: .valueChanged)
    }
    
    @objc private func didSelectResolution(_ sender: UISegmentedControl) {
        if movieFrameRate == .thirty && sender.selectedSegmentIndex == 0 {
            movieResolution = .hd
            viewModel.didChangeResolution(frameRate: .thirty, resolution: .hd, previewView: previewView)
        } else if movieFrameRate == .sixty && sender.selectedSegmentIndex == 0 {
            movieResolution = .hd
            viewModel.didChangeResolution(frameRate: .sixty, resolution: .hd, previewView: previewView)
        } else if movieFrameRate == .thirty && sender.selectedSegmentIndex == 1 {
            movieResolution = .hd4k
            viewModel.didChangeResolution(frameRate: .thirty, resolution: .hd4k, previewView: previewView)
        } else if movieFrameRate == .sixty && sender.selectedSegmentIndex == 1  {
            movieResolution = .hd4k
            viewModel.didChangeResolution(frameRate: .sixty, resolution: .hd4k, previewView: previewView)
        }
    }
    
    private func addFrameRateSegmentedControlTarget() {
        frameRateSegmentedControl.addTarget(self, action: #selector(didSelectFrameRate), for: .valueChanged)
    }
    
    @objc private func didSelectFrameRate(_ sender: UISegmentedControl) {
        if movieResolution == .hd && sender.selectedSegmentIndex == 0 {
            // 1080 30
            movieFrameRate = .thirty
            viewModel.didChange(frameRate: .thirty, resolution: .hd, previewView: previewView)
        } else if movieResolution == .hd && sender.selectedSegmentIndex == 1 {
            // 1080 60
            movieFrameRate = .sixty
            viewModel.didChange(frameRate: .sixty, resolution: .hd, previewView: previewView)
        } else if movieResolution == .hd4k && sender.selectedSegmentIndex == 0 {
            movieFrameRate = .thirty
            // 4k 30
            viewModel.didChange(frameRate: .thirty, resolution: .hd4k, previewView: previewView)
        } else if movieResolution == .hd4k && sender.selectedSegmentIndex == 1 {
            // 4k 60
            movieFrameRate = .sixty
            viewModel.didChange(frameRate: .sixty, resolution: .hd4k, previewView: previewView)
        }
    }
    
    private func addCaptureModeSegmentedControlTarget() {
        captureModeSegmentedControl.addTarget(self, action: #selector(didSelectCaptureMode), for: .valueChanged)
    }
    
    @objc private func didSelectCaptureMode(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            captureButton.isHidden = false
            recordButton.isHidden = true
            movieResolutionSegmentedControl.isHidden = true
            frameRateSegmentedControl.isHidden = true
            recordTimerLabel.isHidden = true
            viewModel.didChangeCapture(mode: .photo)
            
        case 1:
            captureButton.isHidden = true
            recordButton.isHidden = false
            movieResolutionSegmentedControl.isHidden = false
            frameRateSegmentedControl.isHidden = false
            recordTimerLabel.isHidden = false
            viewModel.didChangeCapture(mode: .movie)
            
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
        view.addSubview(frameRateSegmentedControl)
        view.addSubview(movieResolutionSegmentedControl)
        view.addSubview(videoZoomFactorSegmentedControl)
        view.addSubview(captureModeSegmentedControl)
        view.addSubview(recordTimerLabel)
    }
    
    private func adjustLayoutOf(previewView: PreviewView) {
        previewView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        previewView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        previewView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        previewView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    }
    
    private func adjustLayoutOf(captureButton: UIButton) {
        portraitConstraints.append(captureButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -40))
        portraitConstraints.append(captureButton.centerXAnchor.constraint(equalTo: view.centerXAnchor))
    }
    
    private func adjustLayoutOf(recordButton: RecordButton) {
        portraitConstraints.append(recordButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -40))
        portraitConstraints.append(recordButton.centerXAnchor.constraint(equalTo: view.centerXAnchor))
    }
    
    private func adjustLayoutOf(captureModeSegmentedControl: UISegmentedControl) {
        portraitConstraints.append(captureModeSegmentedControl.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -150))
        portraitConstraints.append(captureModeSegmentedControl.centerXAnchor.constraint(equalTo: view.centerXAnchor))
    }
    
    private func adjustLayoutOf(videoZoomFactorSegmentedControl: UISegmentedControl) {
        portraitConstraints.append(videoZoomFactorSegmentedControl.bottomAnchor.constraint(equalTo: captureModeSegmentedControl.topAnchor, constant: -15))
        portraitConstraints.append(videoZoomFactorSegmentedControl.centerXAnchor.constraint(equalTo: view.centerXAnchor))
    }
    
    private func adjustLandscapeLayoutOf(captureButton: UIButton) {
        landscapeConstraints.append(captureButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -15))
        landscapeConstraints.append(captureButton.centerYAnchor.constraint(equalTo: view.centerYAnchor))
    }
    
    private func adjustLandscapeLayoutOf(recordButton: RecordButton) {
        landscapeConstraints.append(recordButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -15))
        landscapeConstraints.append(recordButton.centerYAnchor.constraint(equalTo: view.centerYAnchor))
    }
    
    private func adjustLandscapeLayoutOf(captureModeSegmentedControl: UISegmentedControl) {
        landscapeConstraints.append(captureModeSegmentedControl.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10))
        landscapeConstraints.append(captureModeSegmentedControl.centerXAnchor.constraint(equalTo: view.centerXAnchor))
    }
    
    private func adjustLandscapeLayoutOf(videoZoomFactorSegmentedControl: UISegmentedControl) {
        landscapeConstraints.append(videoZoomFactorSegmentedControl.bottomAnchor.constraint(equalTo: captureModeSegmentedControl.topAnchor, constant: -15))
        landscapeConstraints.append(videoZoomFactorSegmentedControl.centerXAnchor.constraint(equalTo: view.centerXAnchor))
    }
    
    private func adjustLayoutOf(frameRateSegmentedControl: UISegmentedControl) {
        frameRateSegmentedControl.topAnchor.constraint(equalTo: movieResolutionSegmentedControl.bottomAnchor, constant: 15).isActive = true
        frameRateSegmentedControl.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    }
    
    private func adjustLayoutOf(movieResolutionSegmentedControl: UISegmentedControl) {
        movieResolutionSegmentedControl.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 15).isActive = true
        movieResolutionSegmentedControl.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    }
    
    private func adjustLayoutOf(recordingTimerLabel: UILabel) {
        recordTimerLabel.bottomAnchor.constraint(equalTo: videoZoomFactorSegmentedControl.topAnchor, constant: -15).isActive = true
        recordingTimerLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
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
                self.movieResolutionSegmentedControl.isHidden = true
                self.frameRateSegmentedControl.isHidden = true
                self.captureModeSegmentedControl.isHidden = true
                self.viewModel.runTimer()
            } else {
                self.isRecord.toggle()
                recordButton.toggle()
                self.viewModel.didRecord()
                self.presentDishNameTextFieldAlert()
                self.movieResolutionSegmentedControl.isHidden = false
                self.frameRateSegmentedControl.isHidden = false
                self.captureModeSegmentedControl.isHidden = false
                self.viewModel.cancelTimer()
            }
        }
        recordButton.addAction(action, for: .touchUpInside)
    }
    
    private func presentDishNameTextFieldAlert() {
        let alertController = UIAlertController(title: "음식 이름", message: nil, preferredStyle: .alert)
        alertController.addTextField()
        
        let cancelAction = UIAlertAction(title: "취소", style: .destructive) { _ in
            self.viewModel.resetTimer()
        }
        
        alertController.addAction(cancelAction)
        
        let confirmAction = UIAlertAction(title: "확인", style: .default) { _ in
            if let textFields = alertController.textFields {
                if let textField = textFields.first {
                    if let text = textField.text, !text.isEmpty {
                        self.viewModel.didLoadTasteView(dishName: text)
                        self.viewModel.resetTimer()
                    } else {
                        print("Text must not be empty.")
                    }
                } else {
                    print("Cannot find text field.")
                }
            }
        }
        alertController.addAction(confirmAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
}

extension StudioViewController: AVCapturePhotoOutputReadinessCoordinatorDelegate {
    func readinessCoordinator(_ coordinator: AVCapturePhotoOutputReadinessCoordinator, captureReadinessDidChange captureReadiness: AVCapturePhotoOutput.CaptureReadiness) {
        captureButton.isUserInteractionEnabled = (captureReadiness == .ready) ? true: false
    }
}
