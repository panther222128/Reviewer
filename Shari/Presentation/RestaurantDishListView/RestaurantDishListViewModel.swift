//
//  ReviewDetailViewModel.swift
//  Reviewer
//
//  Created by Horus on 4/14/24.
//

import Foundation
import Combine

// MARK: - Boilerplate
protocol RestaurantDishListViewModel: RestaurantDishListDataSource {
    var isDeleteImmediate: Bool { get }
    var listItemsPublisher: AnyPublisher<[RestaurantDishListItemViewModel], Never> { get }
    var restaurantNamePublisher: AnyPublisher<String, Never> { get }
    
    func loadTitle()
    func loadDishes()
    func didSelectRow(at indexPath: IndexPath)
    func didDeleteDish(at indexPath: IndexPath)
    func didLoadStudio()
    func didLoadTasteView(with dishName: String)
    func loadIsDeleteImmediate()
}

struct RestaurantDishListViewModelActions {
    let showDishDetail: (_ restaurantId: String, _ dish: Dish) -> Void
    let showStudio: (_ restaurantId: String, _ restaurantName: String) -> Void
    let showTastes: (_ restaurantId: String, _ restaurantName: String, _ dishName: String, _ thumbnailImageData: Data?) -> Void
}

final class DefaultRestaurantDishListViewModel: RestaurantDishListViewModel {
    
    private let repository: ReviewListRepository
    private let settingsRepository: SettingsRepository
    private let actions: RestaurantDishListViewModelActions
    private let restaurantId: String
    private let restaurantName: String
    private let restaurantNameSubject: CurrentValueSubject<String, Never>
    private(set) var isDeleteImmediate: Bool
    private var dishes: [Dish]
    private var listItems: [RestaurantDishListItemViewModel]
    private let listItemsSubject: CurrentValueSubject<[RestaurantDishListItemViewModel], Never>
    
    var listItemsPublisher: AnyPublisher<[RestaurantDishListItemViewModel], Never> {
        return listItemsSubject.eraseToAnyPublisher()
    }
    var restaurantNamePublisher: AnyPublisher<String, Never> {
        return restaurantNameSubject.eraseToAnyPublisher()
    }
    
    init(repository: ReviewListRepository, settingsRepository: SettingsRepository, actions: RestaurantDishListViewModelActions, id: String, restaurantName: String) {
        self.restaurantId = id
        self.restaurantName = restaurantName
        self.restaurantNameSubject = .init("")
        self.isDeleteImmediate = false
        self.dishes = []
        self.listItems = []
        self.listItemsSubject = .init([])
        self.repository = repository
        self.settingsRepository = settingsRepository
        self.actions = actions
    }
    
    func loadTitle() {
        restaurantNameSubject.send(restaurantName)
    }
    
    func loadDishes() {
        repository.fetchDishes(restaurantId: restaurantId) { [weak self] result in
            switch result {
            case .success(let dishes):
                if let self = self {
                    self.dishes = dishes.sorted(by: { $0.date < $1.date } )
                    self.listItems = self.dishes.map { .init(name: $0.name) }
                    self.listItemsSubject.send(self.listItems)
                } else {
                    print("View model is empty.")
                }
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func didSelectRow(at indexPath: IndexPath) {
        let dish = dishes[indexPath.row]
        actions.showDishDetail(restaurantId, dish)
    }
    
    func didDeleteDish(at indexPath: IndexPath) {
        let dishId = dishes[indexPath.row].id
        repository.deleteDish(restaurantId: restaurantId, dishId: dishId)
    }
    
    func didLoadStudio() {
        actions.showStudio(restaurantId, restaurantName)
    }
    
    func didLoadTasteView(with dishName: String) {
        actions.showTastes(restaurantId, restaurantName, dishName, nil)
    }
    
    func loadIsDeleteImmediate() {
        settingsRepository.fetchIsDeleteImmediate { [weak self] result in
            switch result {
            case .success(let isDeleteImmediate):
                self?.isDeleteImmediate = isDeleteImmediate
                
            case .failure(let failure):
                return
                
            }
        }
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
