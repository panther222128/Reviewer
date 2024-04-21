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
    lazy var settingsStorage: SettingsStorage = DefaultSettingsStorage()
    
    init(dependencies: Dependencies) {
        self.dependencies = dependencies
    }
    
    func makeViewFlowCoordinator(tabBarController: UITabBarController) -> ViewFlowCoordinator {
        return ViewFlowCoordinator(tabBarController: tabBarController, dependencies: self)
    }
    
    func makeReviewListRepository() -> ReviewListRepository {
        return DefaultReviewListRepository(storage: reviewListStorage)
    }
    
    func makeSettingsRepository() -> SettingsRepository {
        return DefaultSettingsRepository(storage: settingsStorage)
    }
    
    func makeRestaurantListViewModel(actions: RestaurantListViewModelActions) -> RestaurantListViewModel {
        return DefaultRestaurantListViewModel(repository: makeReviewListRepository(), settingsRepository: makeSettingsRepository(), actions: actions)
    }
    
    func makeRestaurantListViewController(actions: RestaurantListViewModelActions) -> RestaurantListViewController {
        return RestaurantListViewController.create(with: makeRestaurantListViewModel(actions: actions))
    }
    
    func makeStudioUseCase() -> StudioUseCase  {
        return DefaultStudioUseCase(studio: Studio())
    }
    
    func makeStudioViewModel(actions: StudioViewModelActions, id: String, restaurantName: String) -> StudioViewModel {
        return DefaultStudioViewModel(studio: Studio(), useCase: makeStudioUseCase(), actions: actions, id: id, restaurantName: restaurantName)
    }
    
    func makeStudioViewController(actions: StudioViewModelActions, id: String, restaurantName: String) -> StudioViewController {
        return StudioViewController.create(with: makeStudioViewModel(actions: actions, id: id, restaurantName: restaurantName))
    }
    
    func makeTasteListViewModel(restaurantId: String, restaurantName: String, dishName: String) -> TasteListViewModel {
        return DefaultTasteListViewModel(repository: makeReviewListRepository(), restaurantId: restaurantId, restaurantName: restaurantName, dishName: dishName)
    }
    
    func makeTasteListViewController(restaurantId: String, restaurantName: String, dishName: String) -> TasteListViewController {
        return TasteListViewController.create(with: makeTasteListViewModel(restaurantId: restaurantId, restaurantName: restaurantName, dishName: dishName))
    }
    
    func makeSettingsViewModel() -> SettingsViewModel {
        return DefaultSettingsViewModel(repository: makeSettingsRepository())
    }
    
    func makeSettingsViewController() -> SettingsViewController {
        return SettingsViewController.create(with: makeSettingsViewModel())
    }
    
    func makeDishListViewModel(id: String, restaurantName: String, actions: RestaurantDishListViewModelActions) -> RestaurantDishListViewModel {
        return DefaultRestaurantDishListViewModel(repository: makeReviewListRepository(), actions: actions, id: id, restaurantName: restaurantName)
    }
    
    func makeRestaurantDishListViewController(id: String, restaurantName: String, actions: RestaurantDishListViewModelActions) -> RestaurantDishListViewController {
        return RestaurantDishListViewController.create(with: makeDishListViewModel(id: id, restaurantName: restaurantName, actions: actions))
    }
    
    func makeDishDetailViewModel(restaurantId: String, dishId: String, tastes: [String], dishName: String) -> DishDetailViewModel {
        return DefaultDishDetailViewModel(repository: makeReviewListRepository(), restaurantId: restaurantId, dishId: dishId, tastes: tastes, dishName: dishName)
    }
    
    func makeDishDetailViewController(restaurantId: String, dishId: String, tastes: [String], dishName: String) -> DishDetailViewController {
        return DishDetailViewController.create(with: makeDishDetailViewModel(restaurantId: restaurantId, dishId: dishId, tastes: tastes, dishName: dishName))
    }
    
}
