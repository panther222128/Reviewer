//
//  ViewFlowCoordinator.swift
//  Reviewer
//
//  Created by Horus on 4/7/24.
//

import UIKit

protocol ViewFlowCoordinatorDependencies {
    func makeReviewListViewController(actions: ReviewListViewModelActions) -> ReviewListViewController
    func makeStudioViewController(actions: StudioViewModelActions, restaurantName: String) -> StudioViewController
    func makeTasteListViewController(dish: Dish, restaurantName: String) -> TasteListViewController
    
    func makeSettingsViewController() -> SettingsViewController
    
    func makeReviewDetailViewController(id: String) -> ReviewDetailViewController
}

final class ViewFlowCoordinator {
    
    private var reviewListNavigator: UINavigationController?
    private var settingsListNavigator: UINavigationController?
    private weak var tabBarController: UITabBarController?
    private let dependencies: ViewFlowCoordinatorDependencies
    
    private weak var reviewListViewController: ReviewListViewController?
    private weak var studioViewController: StudioViewController?
    private weak var tasteListViewController: TasteListViewController?
    private weak var settingsViewController: SettingsViewController?
    
    private weak var reviewDetailViewController: ReviewDetailViewController?
    
    init(tabBarController: UITabBarController, dependencies: ViewFlowCoordinatorDependencies) {
        self.tabBarController = tabBarController
        self.dependencies = dependencies
    }
    
    func start() {
        tabBarController?.tabBar.tintColor = .black
        tabBarController?.tabBar.unselectedItemTintColor = .black
        
        let reviewListViewController = dependencies.makeReviewListViewController(actions: .init(showStudioView: showStudioView(with:), showReviewDetailView: showReviewDetailView(id:)))
        self.reviewListViewController = reviewListViewController
        
        let reviewListViewTabBarItem = UITabBarItem(title: "List", image: UIImage(systemName: "list.bullet"), tag: 0)
        
        
        
        
        
        let settingsViewController = dependencies.makeSettingsViewController()
        self.settingsViewController = settingsViewController
        
        let settingsListViewTabBarItem = UITabBarItem(title: "Settings", image: UIImage(systemName: "gear"), tag: 1)
        
        
        
        reviewListNavigator = UINavigationController()
        settingsListNavigator = UINavigationController()
        
        reviewListNavigator?.tabBarItem = reviewListViewTabBarItem
        settingsListNavigator?.tabBarItem = settingsListViewTabBarItem
        
        guard let reviewListNavigator = reviewListNavigator else { return }
        guard let settingsListNavigator = settingsListNavigator else { return }
        
        tabBarController?.viewControllers = [reviewListNavigator, settingsListNavigator]
        
        self.reviewListNavigator?.pushViewController(reviewListViewController, animated: true)
        self.settingsListNavigator?.pushViewController(settingsViewController, animated: true)
    }
    
    private func showStudioView(with restaurantName: String) {
        let viewController = dependencies.makeStudioViewController(actions: .init(showTasteListView: showTasteListView), restaurantName: restaurantName)
        studioViewController = viewController
        reviewListNavigator?.pushViewController(viewController, animated: true)
    }
    
    private func showTasteListView(with dish: Dish, restaurantName: String) {
        let viewController = dependencies.makeTasteListViewController(dish: dish, restaurantName: restaurantName)
        tasteListViewController = viewController
        studioViewController?.navigationController?.pushViewController(viewController, animated: true)
    }
    
    private func showReviewDetailView(id: String) {
        let viewController = dependencies.makeReviewDetailViewController(id: id)
        reviewDetailViewController = viewController
        reviewListNavigator?.pushViewController(viewController, animated: true)
    }
    
}
