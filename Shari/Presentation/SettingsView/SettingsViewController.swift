//
//  SettingsViewController.swift
//  Reviewer
//
//  Created by Horus on 4/11/24.
//

import UIKit
import Combine

final class SettingsViewController: UIViewController {
    
    private var viewModel: SettingsViewModel!
    
    private let settingsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        return stackView
    }()
    
    private let deleteModeSwitchSettingView: SwitchSettingView = {
        let switchSettingView = SwitchSettingView(title: "삭제 시 확인 묻기", frame: .zero)
        switchSettingView.translatesAutoresizingMaskIntoConstraints = false
        return switchSettingView
    }()
    
    private var cancellables: Set<AnyCancellable> = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        navigationController?.navigationBar.isHidden = true
        
        addSubviews()
        
        adjustLayoutOf(settingsStackView: settingsStackView)
        
        subscribe(isDeleteImmediatePublisher: viewModel.isDeleteImmediatePublisher)
        
        addTargetOfDeleteModeSwitch()
        
        viewModel.loadIsDeleteImmediate()
    }
    
    static func create(with viewModel: SettingsViewModel) -> SettingsViewController {
        let viewController = SettingsViewController()
        viewController.viewModel = viewModel
        return viewController
    }
    
    private func subscribe(isDeleteImmediatePublisher: AnyPublisher<Bool, Never>) {
        isDeleteImmediatePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isDeleteImmediate in
                self?.deleteModeSwitchSettingView.setSettingSwitch(to: isDeleteImmediate)
            }
            .store(in: &cancellables)
    }
    
    private func addTargetOfDeleteModeSwitch() {
        deleteModeSwitchSettingView.addSettingSwitch(target: self, action: #selector(didToggleSwitch), for: .valueChanged)
    }
    
    @objc private func didToggleSwitch(_ sender: UISwitch) {
        if sender.isOn {
            viewModel.didToggleSwitch(to: false)
        } else {
            viewModel.didToggleSwitch(to: true)
        }
    }
    
}

extension SettingsViewController {
    private func addSubviews() {
        view.addSubview(settingsStackView)
        settingsStackView.addArrangedSubview(deleteModeSwitchSettingView)
    }
    
    private func adjustLayoutOf(settingsStackView: UIStackView) {
        settingsStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        settingsStackView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        settingsStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        settingsStackView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    }
}
