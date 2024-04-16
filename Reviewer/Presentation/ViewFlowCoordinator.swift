//
//  ViewFlowCoordinator.swift
//  Reviewer
//
//  Created by Horus on 4/7/24.
//

import UIKit

protocol ViewFlowCoordinatorDependencies {
    func makeRestaurantListViewController(actions: RestaurantListViewModelActions) -> RestaurantListViewController
    func makeStudioViewController(actions: StudioViewModelActions, restaurantName: String, id: String) -> StudioViewController
    func makeTasteListViewController(dishName: String, restaurantName: String, restaurantId: String) -> TasteListViewController
    
    func makeSettingsViewController() -> SettingsViewController
    
    func makeRestaurantDishListViewController(id: String, actions: RestaurantDishListViewModelActions) -> RestaurantDishListViewController
    func makeDishDetailViewController(tastes: [String]) -> DishDetailViewController
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
        
        let reviewListViewController = dependencies.makeRestaurantListViewController(actions: .init(showStudioView: showStudioView(with:id:), showRestaurantDishListView: showRestaurantDishListView(id:)))
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
    
    private func showStudioView(with restaurantName: String, id: String) {
        let viewController = dependencies.makeStudioViewController(actions: .init(showTasteListView: showTasteListView), restaurantName: restaurantName, id: id)
        studioViewController = viewController
        restaurantListNavigator?.pushViewController(viewController, animated: true)
    }
    
    private func showTasteListView(dishName: String, restaurantName: String, restaurantId: String) {
        let viewController = dependencies.makeTasteListViewController(dishName: dishName, restaurantName: restaurantName, restaurantId: restaurantId)
        tasteListViewController = viewController
        studioViewController?.navigationController?.pushViewController(viewController, animated: true)
    }
    
    private func showRestaurantDishListView(id: String) {
        let viewController = dependencies.makeRestaurantDishListViewController(id: id, actions: .init(showDishDetail: showDishDetailView(with:)))
        restaurantDishListViewController = viewController
        restaurantListNavigator?.pushViewController(viewController, animated: true)
    }
    
    private func showDishDetailView(with tastes: [String]) {
        let viewController = dependencies.makeDishDetailViewController(tastes: tastes)
        dishDetailViewController = viewController
        restaurantDishListViewController?.navigationController?.pushViewController(viewController, animated: true)
    }
    
}
