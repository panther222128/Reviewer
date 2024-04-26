//
//  ReviewListViewModel.swift
//  Reviewer
//
//  Created by Horus on 4/7/24.
//

import Foundation
import Combine

// MARK: - Boilerplate
protocol RestaurantListViewModel: RestaurantListDataSource {
    var isDeleteImmediate: Bool { get }
    var listItemViewModelPublisher: AnyPublisher<[RestaurantListItemViewModel], Never> { get }
    
    func loadListItem()
    func didPressedAlertConfirmButton(with restaurantName: String)
    func didSelectItem(at indexPath: IndexPath)
    func didAddRestaurant(name: String)
    func didDeleteRestaurant(at indexPath: IndexPath)
    func loadIsDeleteImmediate()
}

struct RestaurantListViewModelActions {
    let showStudioView: (_ restaurantId: String, _ restaurantName: String) -> Void
    let showRestaurantDishListView: (_ restaurantId: String, _ restaurantName: String) -> Void
}

final class DefaultRestaurantListViewModel: RestaurantListViewModel {
    
    private let repository: ReviewListRepository
    private let settingsRepository: SettingsRepository
    private let actions: RestaurantListViewModelActions
    private var restaurants: [Restaurant]
    private var restaurantId: String
    private(set) var isDeleteImmediate: Bool
    private var listItemViewModels: [RestaurantListItemViewModel]
    private var listItemViewModelSubject: CurrentValueSubject<[RestaurantListItemViewModel], Never>
    var listItemViewModelPublisher: AnyPublisher<[RestaurantListItemViewModel], Never> {
        return listItemViewModelSubject.eraseToAnyPublisher()
    }
    
    init(repository: ReviewListRepository, settingsRepository: SettingsRepository, actions: RestaurantListViewModelActions) {
        self.repository = repository
        self.settingsRepository = settingsRepository
        self.actions = actions
        self.restaurants = []
        self.restaurantId = ""
        self.isDeleteImmediate = false
        self.listItemViewModels = []
        self.listItemViewModelSubject = .init([])
    }
    
    func loadListItem() {
        repository.fetchRestaurants { [weak self] result in
            switch result {
            case .success(let restaurants):
                if let self = self {
                    self.restaurants = restaurants.sorted(by: { $0.date < $1.date } )
                    self.listItemViewModels = self.restaurants.map { .init(restaurantName: $0.name, date: $0.date) }
                    self.listItemViewModelSubject.send(self.listItemViewModels)
                } else {
                    print("Cannot find view model.")
                }
                
            case .failure(let error):
                print(error)
                
            }
        }
    }
    
    func didPressedAlertConfirmButton(with restaurantName: String) {
        actions.showStudioView(restaurantId, restaurantName)
    }
    
    func didSelectItem(at indexPath: IndexPath) {
        actions.showRestaurantDishListView(restaurants[indexPath.row].id, restaurants[indexPath.row].name)
    }
    
    func didAddRestaurant(name: String) {
        let id = UUID().uuidString
        restaurantId = id
        repository.saveRestaurant(restairamtId: id, name: name)
    }
    
    func didDeleteRestaurant(at indexPath: IndexPath) {
        let restaurantId = restaurants[indexPath.row].id
        repository.deleteRestaurant(restaurantId: restaurantId)
        restaurants.remove(at: indexPath.row)
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

extension DefaultRestaurantListViewModel: RestaurantListDataSource {
    func cellForRow(at indexPath: IndexPath) -> RestaurantListItemViewModel {
        return listItemViewModels[indexPath.row]
    }
    
    func numberOfRowsIn(section: Int) -> Int {
        return listItemViewModels.count
    }
}
