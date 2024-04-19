//
//  SettingsRepository.swift
//  Reviewer
//
//  Created by Horus on 4/19/24.
//

import Foundation

protocol SettingsRepository {
    func fetchIsDeleteImmediate(completion: @escaping (Result<Bool, Error>) -> Void)
    func setIsDeleteImmediate(to value: Bool, completion: @escaping (Result<Bool, Error>) -> Void)
}
