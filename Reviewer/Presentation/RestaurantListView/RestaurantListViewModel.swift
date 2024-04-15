//
//  ReviewListViewModel.swift
//  Reviewer
//
//  Created by Horus on 4/7/24.
//

import Foundation
import Combine

protocol RestaurantListViewModel: RestaurantListDataSource {
    var listItemViewModelPublisher: AnyPublisher<[RestaurantListItemViewModel], Never> { get }
    
    func loadListItem()
    func didPressedAlertConfirmButton(with restaurantName: String)
    func didSelectItem(at indexPath: IndexPath)
}

struct RestaurantListViewModelActions {
    let showStudioView: (String) -> Void
    let showRestaurantDishListView: (String) -> Void
}

final class DefaultRestaurantListViewModel: RestaurantListViewModel {
    
    private let repository: ReviewListRepository
    private let actions: RestaurantListViewModelActions
    private let restaurants: [Restaurant]
    private var listItemViewModels: [RestaurantListItemViewModel]
    private var listItemViewModelSubject: CurrentValueSubject<[RestaurantListItemViewModel], Never>
    var listItemViewModelPublisher: AnyPublisher<[RestaurantListItemViewModel], Never> {
        return listItemViewModelSubject.eraseToAnyPublisher()
    }
    
    init(repository: ReviewListRepository, actions: RestaurantListViewModelActions) {
        self.repository = repository
        self.actions = actions
        self.restaurants = []
        self.listItemViewModels = []
        self.listItemViewModelSubject = .init([])
    }
    
    func loadListItem() {
        listItemViewModels = []
        listItemViewModelSubject.send(listItemViewModels)
    }
    
    func didPressedAlertConfirmButton(with restaurantName: String) {
        actions.showStudioView(restaurantName)
    }
    
    func didSelectItem(at indexPath: IndexPath) {
        actions.showRestaurantDishListView(restaurants[indexPath.row].id)
    }
    
}

extension DefaultRestaurantListViewModel: RestaurantListDataSource {
    func cellForRow(at indexPath: IndexPath) -> RestaurantListItemViewModel {
        return listItemViewModels[indexPath.row]
    }
    
    func numberOfRowsIn(section: Int) -> Int {
        return listItemViewModels.count
    }
}
