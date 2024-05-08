//
//  SettingsStorage.swift
//  Reviewer
//
//  Created by Horus on 4/19/24.
//

import Foundation

protocol SettingsStorage {
    func setIsDeleteImmediate(to value: Bool, completion: @escaping (Result<Bool, Error>) -> Void)
    func fetchIsDeleteImmediate(completion: @escaping (Result<Bool, Error>) -> Void)
}

final class DefaultSettingsStorage: SettingsStorage {
    
    private var userDefaults: UserDefaults
    private let backgroundQueue: DispatchQueue
    
    init(userDefaults: UserDefaults = UserDefaults.standard, backgroundQueue: DispatchQueue = DispatchQueue.global(qos: .userInitiated)) {
        self.userDefaults = userDefaults
        self.backgroundQueue = backgroundQueue
    }
    
    func setIsDeleteImmediate(to value: Bool, completion: @escaping (Result<Bool, Error>) -> Void) {
        backgroundQueue.async { [weak self] in
            guard let self = self else { return }
            self.userDefaults.set(value, forKey: "isDeleteImmediate")
            completion(.success(value))
        }
    }
    
    func fetchIsDeleteImmediate(completion: @escaping (Result<Bool, Error>) -> Void) {
        backgroundQueue.async { [weak self] in
            guard let self = self else { return }
            let isDeleteImmediate = self.userDefaults.bool(forKey: "isDeleteImmediate")
            completion(.success(isDeleteImmediate))
        }
    }
    
}
