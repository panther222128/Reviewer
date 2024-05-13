//
//  SceneDIContainer.swift
//  Reviewer
//
//  Created by Horus on 4/7/24.
//

import UIKit

final class SceneDIContainer: ViewFlowCoordinatorDependencies {
    
    struct Dependencies {
        let fileGenerator: FileGenerator
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
        return DefaultReviewListRepository(storage: reviewListStorage, fileGenerator: dependencies.fileGenerator)
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
    
    func makeTasteListViewModel(restaurantId: String, restaurantName: String, dishName: String, thumbnailImageData: Data?) -> TasteListViewModel {
        return DefaultTasteListViewModel(repository: makeReviewListRepository(), restaurantId: restaurantId, restaurantName: restaurantName, dishName: dishName, thumbnailImageData: thumbnailImageData)
    }
    
    func makeTasteListViewController(restaurantId: String, restaurantName: String, dishName: String, thumbnailImageData: Data?) -> TasteListViewController {
        return TasteListViewController.create(with: makeTasteListViewModel(restaurantId: restaurantId, restaurantName: restaurantName, dishName: dishName, thumbnailImageData: thumbnailImageData))
    }
    
    func makeGlossaryViewModel() -> GlossaryViewModel {
        return DefaultGlossaryViewModel()
    }
    
    func makeGlossaryViewController() -> GlossaryViewController {
        return GlossaryViewController.create(with: makeGlossaryViewModel())
    }
    
    func makeSettingsViewModel() -> SettingsViewModel {
        return DefaultSettingsViewModel(repository: makeSettingsRepository())
    }
    
    func makeSettingsViewController() -> SettingsViewController {
        return SettingsViewController.create(with: makeSettingsViewModel())
    }
    
    func makeDishListViewModel(id: String, restaurantName: String, actions: RestaurantDishListViewModelActions) -> RestaurantDishListViewModel {
        return DefaultRestaurantDishListViewModel(repository: makeReviewListRepository(), settingsRepository: makeSettingsRepository(), actions: actions, id: id, restaurantName: restaurantName)
    }
    
    func makeRestaurantDishListViewController(id: String, restaurantName: String, actions: RestaurantDishListViewModelActions) -> RestaurantDishListViewController {
        return RestaurantDishListViewController.create(with: makeDishListViewModel(id: id, restaurantName: restaurantName, actions: actions))
    }
    
    func makeDishDetailViewModel(restaurantId: String, dish: Dish) -> DishDetailViewModel {
        return DefaultDishDetailViewModel(repository: makeReviewListRepository(), restaurantId: restaurantId, dish: dish)
    }
    
    func makeDishDetailViewController(restaurantId: String, dish: Dish) -> DishDetailViewController {
        return DishDetailViewController.create(with: makeDishDetailViewModel(restaurantId: restaurantId, dish: dish))
    }
    
}
