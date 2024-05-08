//
//  DefaultSettingsRepository.swift
//  Reviewer
//
//  Created by Horus on 4/19/24.
//

import Foundation

final class DefaultSettingsRepository: SettingsRepository {
    
    private let storage: SettingsStorage
    
    init(storage: SettingsStorage) {
        self.storage = storage
    }
    
    func fetchIsDeleteImmediate(completion: @escaping (Result<Bool, Error>) -> Void) {
        storage.fetchIsDeleteImmediate(completion: completion)
    }
    
    func setIsDeleteImmediate(to value: Bool, completion: @escaping (Result<Bool, Error>) -> Void) {
        storage.setIsDeleteImmediate(to: value, completion: completion)
    }
    
}
