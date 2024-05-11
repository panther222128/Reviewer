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
    func makeTasteListViewController(restaurantId: String, restaurantName: String, dishName: String, thumbnailImageData: Data?) -> TasteListViewController
    
    func makeGlossaryViewController() -> GlossaryViewController
    
    func makeSettingsViewController() -> SettingsViewController
    
    func makeRestaurantDishListViewController(id: String, restaurantName: String, actions: RestaurantDishListViewModelActions) -> RestaurantDishListViewController
    func makeDishDetailViewController(restaurantId: String, dish: Dish) -> DishDetailViewController
}

final class ViewFlowCoordinator {
    
    private var restaurantListNavigator: UINavigationController?
    private var settingsListNavigator: UINavigationController?
    private var glossaryNavigator: UINavigationController?
    private weak var tabBarController: UITabBarController?
    private let dependencies: ViewFlowCoordinatorDependencies
    
    private weak var restaurantListViewController: RestaurantListViewController?
    private weak var studioViewController: StudioViewController?
    private weak var tasteListViewController: TasteListViewController?
    private weak var glossaryViewController: GlossaryViewController?
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
        
        let reviewListViewTabBarItem = UITabBarItem(title: String(localized: "Tab Item Omakase"), image: UIImage(systemName: "list.bullet"), tag: 0)
        
        let glossaryViewcontroller = dependencies.makeGlossaryViewController()
        self.glossaryViewController = glossaryViewcontroller
        
        let glossaryViewTabBarItem = UITabBarItem(title: String(localized: "Tab Item Glossary"), image: UIImage(systemName: "book.closed"), tag: 1)
        
        let settingsViewController = dependencies.makeSettingsViewController()
        self.settingsViewController = settingsViewController
        
        let settingsListViewTabBarItem = UITabBarItem(title: String(localized: "Tab Item Settings"), image: UIImage(systemName: "gear"), tag: 2)
        
        restaurantListNavigator = UINavigationController()
        glossaryNavigator = UINavigationController()
        settingsListNavigator = UINavigationController()
        
        restaurantListNavigator?.tabBarItem = reviewListViewTabBarItem
        glossaryNavigator?.tabBarItem = glossaryViewTabBarItem
        settingsListNavigator?.tabBarItem = settingsListViewTabBarItem
        
        guard let reviewListNavigator = restaurantListNavigator else { return }
        guard let glossaryNavigator = glossaryNavigator else { return }
        guard let settingsListNavigator = settingsListNavigator else { return }
        
        tabBarController?.viewControllers = [reviewListNavigator, glossaryNavigator, settingsListNavigator]
        
        self.restaurantListNavigator?.pushViewController(reviewListViewController, animated: true)
        self.glossaryNavigator?.pushViewController(glossaryViewcontroller, animated: true)
        self.settingsListNavigator?.pushViewController(settingsViewController, animated: true)
    }
    
    private func showStudioView(id: String, restaurantName: String) {
        let viewController = dependencies.makeStudioViewController(actions: .init(showTasteListView: showTasteListView), id: id, restaurantName: restaurantName)
        studioViewController = viewController
        restaurantListNavigator?.pushViewController(viewController, animated: true)
    }
    
    private func showTasteListView(restaurantId: String, restaurantName: String, dishName: String, thumbnailImageData: Data?) {
        let viewController = dependencies.makeTasteListViewController(restaurantId: restaurantId, restaurantName: restaurantName, dishName: dishName, thumbnailImageData: thumbnailImageData)
        tasteListViewController = viewController
        studioViewController?.navigationController?.pushViewController(viewController, animated: true)
    }
    
    // Test needed when this method is integrated with above method.
    private func showTasteListViewFromDishList(restaurantId: String, restaurantName: String, dishName: String, thumbnailImageData: Data?) {
        let viewController = dependencies.makeTasteListViewController(restaurantId: restaurantId, restaurantName: restaurantName, dishName: dishName, thumbnailImageData: thumbnailImageData)
        tasteListViewController = viewController
        restaurantListNavigator?.pushViewController(viewController, animated: true)
    }
    
    private func showRestaurantDishListView(id: String, restaurantName: String) {
        let viewController = dependencies.makeRestaurantDishListViewController(id: id, restaurantName: restaurantName, actions: .init(showDishDetail: showDishDetailView(restaurantId:dish:), showStudio: showStudioView(id:restaurantName:), showTastes: showTasteListViewFromDishList(restaurantId:restaurantName:dishName:thumbnailImageData:)))
        restaurantDishListViewController = viewController
        restaurantListNavigator?.pushViewController(viewController, animated: true)
    }
    
    private func showDishDetailView(restaurantId: String, dish: Dish) {
        let viewController = dependencies.makeDishDetailViewController(restaurantId: restaurantId, dish: dish)
        dishDetailViewController = viewController
        restaurantDishListViewController?.navigationController?.pushViewController(viewController, animated: true)
    }
    
}
