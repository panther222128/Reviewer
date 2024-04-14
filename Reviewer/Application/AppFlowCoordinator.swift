//
//  AppFlowCoordinator.swift
//  Reviewer
//
//  Created by Horus on 4/7/24.
//

import UIKit

final class AppFlowCoordinator {

    private let tabBarController: UITabBarController
    private let appDIContainer: AppDIContainer
    
    init(tabBarController: UITabBarController, appDIContainer: AppDIContainer) {
        self.tabBarController = tabBarController
        self.appDIContainer = appDIContainer
    }
    
    func start() {
        let sceneDIContainer = appDIContainer.makeSceneDIContainer()
        let flow = sceneDIContainer.makeViewFlowCoordinator(tabBarController: tabBarController)
        flow.start()
    }
    
}
