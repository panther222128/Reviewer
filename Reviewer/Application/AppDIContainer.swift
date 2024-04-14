//
//  AppDIContainer.swift
//  Reviewer
//
//  Created by Horus on 4/7/24.
//

import Foundation

final class AppDIContainer {
    
    lazy var appConfiguration = AppConfiguration()
    
    func makeSceneDIContainer() -> SceneDIContainer {
        let dependencies: SceneDIContainer.Dependencies = .init()
        return SceneDIContainer(dependencies: dependencies)
    }
    
}
