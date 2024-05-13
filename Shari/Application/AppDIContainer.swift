//
//  AppDIContainer.swift
//  Reviewer
//
//  Created by Horus on 4/7/24.
//

import Foundation

final class AppDIContainer {
    
    lazy var appConfiguration = AppConfiguration()
    
    lazy var fileGenerator: FileGenerator = {
        let fileGenerator: FileGenerator = DefaultFileGenerator()
        return fileGenerator
    }()
    
    func makeSceneDIContainer() -> SceneDIContainer {
        let dependencies: SceneDIContainer.Dependencies = .init(fileGenerator: fileGenerator)
        return SceneDIContainer(dependencies: dependencies)
    }
    
}
