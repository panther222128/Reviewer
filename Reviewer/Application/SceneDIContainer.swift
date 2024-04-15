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
    
    func makeReviewListViewModel(actions: ReviewListViewModelActions) -> ReviewListViewModel {
        return DefaultReviewListViewModel(repository: makeReviewListRepository(), actions: actions)
    }
    
    func makeReviewListViewController(actions: ReviewListViewModelActions) -> ReviewListViewController {
        return ReviewListViewController.create(with: makeReviewListViewModel(actions: actions))
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
    
    func makeReviewDetailViewModel(id: String) -> ReviewDetailViewModel {
        return DefaultReviewDetailViewModel(id: id)
    }
    
    func makeReviewDetailViewController(id: String) -> ReviewDetailViewController {
        return ReviewDetailViewController.create(with: makeReviewDetailViewModel(id: id))
    }
    
}
