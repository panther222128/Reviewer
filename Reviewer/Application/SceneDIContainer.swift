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
    
    func makeStudioViewModel(actions: StudioViewModelActions, restaurantName: String, id: String) -> StudioViewModel {
        return DefaultStudioViewModel(actions: actions, studio: Studio(), useCase: makeStudioUseCase(), restaurantName: restaurantName, id: id)
    }
    
    func makeStudioViewController(actions: StudioViewModelActions, restaurantName: String, id: String) -> StudioViewController {
        return StudioViewController.create(with: makeStudioViewModel(actions: actions, restaurantName: restaurantName, id: id))
    }
    
    func makeTasteListViewModel(dishName: String, restaurantName: String, restaurantId: String) -> TasteListViewModel {
        return DefaultTasteListViewModel(repository: makeReviewListRepository(), dishName: dishName, restaurantName: restaurantName, restaurantId: restaurantId)
    }
    
    func makeTasteListViewController(dishName: String, restaurantName: String, restaurantId: String) -> TasteListViewController {
        return TasteListViewController.create(with: makeTasteListViewModel(dishName: dishName, restaurantName: restaurantName, restaurantId: restaurantId))
    }
    
    func makeSettingsViewController() -> SettingsViewController {
        return SettingsViewController.create()
    }
    
    func makeDishListViewModel(id: String, restaurantName: String, actions: RestaurantDishListViewModelActions) -> RestaurantDishListViewModel {
        return DefaultRestaurantDishListViewModel(id: id, restaurantName: restaurantName, repository: makeReviewListRepository(), actions: actions)
    }
    
    func makeRestaurantDishListViewController(id: String, restaurantName: String, actions: RestaurantDishListViewModelActions) -> RestaurantDishListViewController {
        return RestaurantDishListViewController.create(with: makeDishListViewModel(id: id, restaurantName: restaurantName, actions: actions))
    }
    
    func makeDishDetailViewModel(tastes: [String]) -> DishDetailViewModel {
        return DefaultDishDetailViewModel(tastes: tastes)
    }
    
    func makeDishDetailViewController(tastes: [String]) -> DishDetailViewController {
        return DishDetailViewController.create(with: makeDishDetailViewModel(tastes: tastes))
    }
    
}
