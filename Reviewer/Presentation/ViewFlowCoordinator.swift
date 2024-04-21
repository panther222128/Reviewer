//
//  ViewFlowCoordinator.swift
//  Reviewer
//
//  Created by Horus on 4/7/24.
//

import UIKit

protocol ViewFlowCoordinatorDependencies {
    func makeRestaurantListViewController(actions: RestaurantListViewModelActions) -> RestaurantListViewController
    func makeStudioViewController(actions: StudioViewModelActions, id: String, restaurantName: String) -> StudioViewController
    func makeTasteListViewController(restaurantId: String, restaurantName: String, dishName: String) -> TasteListViewController
    
    func makeSettingsViewController() -> SettingsViewController
    
    func makeRestaurantDishListViewController(id: String, restaurantName: String, actions: RestaurantDishListViewModelActions) -> RestaurantDishListViewController
    func makeDishDetailViewController(restaurantId: String, dishId: String, tastes: [String], dishName: String) -> DishDetailViewController
}

final class ViewFlowCoordinator {
    
    private var restaurantListNavigator: UINavigationController?
    private var settingsListNavigator: UINavigationController?
    private weak var tabBarController: UITabBarController?
    private let dependencies: ViewFlowCoordinatorDependencies
    
    private weak var restaurantListViewController: RestaurantListViewController?
    private weak var studioViewController: StudioViewController?
    private weak var tasteListViewController: TasteListViewController?
    private weak var settingsViewController: SettingsViewController?
    
    private weak var restaurantDishListViewController: RestaurantDishListViewController?
    private weak var dishDetailViewController: DishDetailViewController?
    
    init(tabBarController: UITabBarController, dependencies: ViewFlowCoordinatorDependencies) {
        self.tabBarController = tabBarController
        self.dependencies = dependencies
    }
    
    func start() {
        tabBarController?.tabBar.tintColor = .black
        tabBarController?.tabBar.unselectedItemTintColor = .black
        
        let reviewListViewController = dependencies.makeRestaurantListViewController(actions: .init(showStudioView: showStudioView(id:restaurantName:), showRestaurantDishListView: showRestaurantDishListView(id:restaurantName:)))
        self.restaurantListViewController = reviewListViewController
        
        let reviewListViewTabBarItem = UITabBarItem(title: "List", image: UIImage(systemName: "list.bullet"), tag: 0)
        
        let settingsViewController = dependencies.makeSettingsViewController()
        self.settingsViewController = settingsViewController
        
        let settingsListViewTabBarItem = UITabBarItem(title: "Settings", image: UIImage(systemName: "gear"), tag: 1)
        
        restaurantListNavigator = UINavigationController()
        settingsListNavigator = UINavigationController()
        
        restaurantListNavigator?.tabBarItem = reviewListViewTabBarItem
        settingsListNavigator?.tabBarItem = settingsListViewTabBarItem
        
        guard let reviewListNavigator = restaurantListNavigator else { return }
        guard let settingsListNavigator = settingsListNavigator else { return }
        
        tabBarController?.viewControllers = [reviewListNavigator, settingsListNavigator]
        
        self.restaurantListNavigator?.pushViewController(reviewListViewController, animated: true)
        self.settingsListNavigator?.pushViewController(settingsViewController, animated: true)
    }
    
    private func showStudioView(id: String, restaurantName: String) {
        let viewController = dependencies.makeStudioViewController(actions: .init(showTasteListView: showTasteListView), id: id, restaurantName: restaurantName)
        studioViewController = viewController
        restaurantListNavigator?.pushViewController(viewController, animated: true)
    }
    
    private func showTasteListView(restaurantId: String, restaurantName: String, dishName: String) {
        let viewController = dependencies.makeTasteListViewController(restaurantId: restaurantId, restaurantName: restaurantName, dishName: dishName)
        tasteListViewController = viewController
        studioViewController?.navigationController?.pushViewController(viewController, animated: true)
    }
    
    private func showRestaurantDishListView(id: String, restaurantName: String) {
        let viewController = dependencies.makeRestaurantDishListViewController(id: id, restaurantName: restaurantName, actions: .init(showDishDetail: showDishDetailView(restaurantId:dishId:with:dishName:), showStudio: showStudioView(id:restaurantName:)))
        restaurantDishListViewController = viewController
        restaurantListNavigator?.pushViewController(viewController, animated: true)
    }
    
    private func showDishDetailView(restaurantId: String, dishId: String, with tastes: [String], dishName: String) {
        let viewController = dependencies.makeDishDetailViewController(restaurantId: restaurantId, dishId: dishId, tastes: tastes, dishName: dishName)
        dishDetailViewController = viewController
        restaurantDishListViewController?.navigationController?.pushViewController(viewController, animated: true)
    }
    
}
