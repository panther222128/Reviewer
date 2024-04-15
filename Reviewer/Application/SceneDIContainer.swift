//
//  SceneDIContainer.swift
//  Reviewer
//
//  Created by Horus on 4/7/24.
//

import UIKit

final class SceneDIContainer: ViewFlowCoordinatorDependencies {
    
    struct Dependencies {
        
    }
    
    private let dependencies: Dependencies
    
    lazy var reviewListStorage: ReviewListStorage = DefaultReviewListStorage()
    
    init(dependencies: Dependencies) {
        self.dependencies = dependencies
    }
    
    func makeViewFlowCoordinator(tabBarController: UITabBarController) -> ViewFlowCoordinator {
        return ViewFlowCoordinator(tabBarController: tabBarController, dependencies: self)
    }
    
    func makeReviewListRepository() -> ReviewListRepository {
        return DefaultReviewListRepository(storage: reviewListStorage)
    }
    
    func makeRestaurantListViewModel(actions: RestaurantListViewModelActions) -> RestaurantListViewModel {
        return DefaultRestaurantListViewModel(repository: makeReviewListRepository(), actions: actions)
    }
    
    func makeRestaurantListViewController(actions: RestaurantListViewModelActions) -> RestaurantListViewController {
        return RestaurantListViewController.create(with: makeRestaurantListViewModel(actions: actions))
    }
    
    func makeStudioUseCase() -> StudioUseCase  {
        return DefaultStudioUseCase(studio: Studio())
    }
    
    func makeStudioViewModel(actions: StudioViewModelActions, restaurantName: String) -> StudioViewModel {
        return DefaultStudioViewModel(actions: actions, studio: Studio(), useCase: makeStudioUseCase(), restaurantName: restaurantName)
    }
    
    func makeStudioViewController(actions: StudioViewModelActions, restaurantName: String) -> StudioViewController {
        return StudioViewController.create(with: makeStudioViewModel(actions: actions, restaurantName: restaurantName))
    }
    
    func makeTasteListViewModel(dish: Dish, restaurantName: String) -> TasteListViewModel {
        return DefaultTasteListViewModel(dish: dish, restaurantName: restaurantName)
    }
    
    func makeTasteListViewController(dish: Dish, restaurantName: String) -> TasteListViewController {
        return TasteListViewController.create(with: makeTasteListViewModel(dish: dish, restaurantName: restaurantName))
    }
    
    func makeSettingsViewController() -> SettingsViewController {
        return SettingsViewController.create()
    }
    
    func makeDishListViewModel(id: String, actions: RestaurantDishListViewModelActions) -> RestaurantDishListViewModel {
        return DefaultRestaurantDishListViewModel(id: id, repository: makeReviewListRepository(), actions: actions)
    }
    
    func makeRestaurantDishListViewController(id: String, actions: RestaurantDishListViewModelActions) -> RestaurantDishListViewController {
        return RestaurantDishListViewController.create(with: makeDishListViewModel(id: id, actions: actions))
    }
    
    func makeDishDetailViewModel(tastes: [String]) -> DishDetailViewModel {
        return DefaultDishDetailViewModel(tastes: tastes)
    }
    
    func makeDishDetailViewController(tastes: [String]) -> DishDetailViewController {
        return DishDetailViewController.create(with: makeDishDetailViewModel(tastes: tastes))
    }
    
}
