//
//  ReviewDetailViewModel.swift
//  Reviewer
//
//  Created by Horus on 4/14/24.
//

import Foundation
import Combine

protocol RestaurantDishListViewModel: RestaurantDishListDataSource {
    var listItemsPublisher: AnyPublisher<[RestaurantDishListItemViewModel], Never> { get }
    
    func loadDishes()
    func didSelectRow(at indexPath: IndexPath)
}

struct RestaurantDishListViewModelActions {
    let showDishDetail: ([String]) -> Void
}

final class DefaultRestaurantDishListViewModel: RestaurantDishListViewModel {
    
    private let id: String
    private var dishes: [Dish]
    private var listItems: [RestaurantDishListItemViewModel]
    private let listItemsSubject: CurrentValueSubject<[RestaurantDishListItemViewModel], Never>
    private let repository: ReviewListRepository
    private let actions: RestaurantDishListViewModelActions
    
    var listItemsPublisher: AnyPublisher<[RestaurantDishListItemViewModel], Never> {
        return listItemsSubject.eraseToAnyPublisher()
    }
    
    init(id: String, repository: ReviewListRepository, actions: RestaurantDishListViewModelActions) {
        self.id = id
        self.dishes = []
        self.listItems = []
        self.listItemsSubject = .init([])
        self.repository = repository
        self.actions = actions
    }
    
    func loadDishes() {
        repository.fetchDishes(with: id) { [weak self] dishes, error in
            if let dishes {
                if let self = self {
                    self.dishes = dishes
                    self.listItems = self.dishes.map { .init(name: $0.name) }
                    self.listItemsSubject.send(self.listItems)
                } else {
                    print("View model is empty.")
                }
            } else {
                print("Cannot find dishes.")
            }
        }
    }
    
    func didSelectRow(at indexPath: IndexPath) {
        actions.showDishDetail(dishes[indexPath.row].tastes)
    }
    
}

extension DefaultRestaurantDishListViewModel {
    func cellForRow(at indexPath: IndexPath) -> RestaurantDishListItemViewModel {
        return .init(name: dishes[indexPath.row].name)
    }
    
    func numberOfRowsIn(section: Int) -> Int {
        return dishes.count
    }
}
