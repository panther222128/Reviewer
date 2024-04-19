//
//  SettingsViewModel.swift
//  Reviewer
//
//  Created by Horus on 4/19/24.
//

import Foundation
import Combine

protocol SettingsViewModel {
    var isDeleteImmediatePublisher: AnyPublisher<Bool, Never> { get }
    
    func loadIsDeleteImmediate()
    func didToggleSwitch(to value: Bool)
}

final class DefaultSettingsViewModel: SettingsViewModel {
    
    private let repository: SettingsRepository
    private var isDeleteImmediate: Bool
    private let isDeleteImmediateSubject: CurrentValueSubject<Bool, Never>
    
    var isDeleteImmediatePublisher: AnyPublisher<Bool, Never> {
        return isDeleteImmediateSubject.eraseToAnyPublisher()
    }
    
    init(repository: SettingsRepository) {
        self.repository = repository
        self.isDeleteImmediate = false
        self.isDeleteImmediateSubject = .init(false)
    }
    
    func loadIsDeleteImmediate() {
        repository.fetchIsDeleteImmediate { [weak self] result in
            switch result {
            case .success(let isImmediate):
                guard let self = self else { return }
                self.isDeleteImmediate = isImmediate
                self.isDeleteImmediateSubject.send(self.isDeleteImmediate)
                
            case .failure(_):
                return
                
            }
        }
    }
    
    func didToggleSwitch(to value: Bool) {
        repository.setIsDeleteImmediate(to: value) { result in
            switch result {
            case .success(_):
                return
                
            case .failure(_):
                return
                
            }
        }
    }
    
}
