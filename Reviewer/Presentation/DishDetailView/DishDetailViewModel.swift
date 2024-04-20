//
//  DishDetailViewModel.swift
//  Reviewer
//
//  Created by Jun Ho JANG on 4/15/24.
//

import Foundation
import Combine

protocol DishDetailViewModel: DishDetailListDataSource {
    var tastesPublisher: AnyPublisher<[String], Never> { get }
    
    func loadTastes()
    func add(taste: String)
    func didLoadTastes()
}

final class DefaultDishDetailViewModel: DishDetailViewModel {
    
    private let repository: ReviewListRepository
    private let restaurantId: String
    private let dishId: String
    private var tastes: [String]
    private let tastesSubject: CurrentValueSubject<[String], Never>
    var tastesPublisher: AnyPublisher<[String], Never> {
        return tastesSubject.eraseToAnyPublisher()
    }
    
    init(repository: ReviewListRepository, restaurantId: String, dishId: String, tastes: [String]) {
        self.repository = repository
        self.restaurantId = restaurantId
        self.dishId = dishId
        self.tastes = tastes
        self.tastesSubject = .init([])
    }
    
    func loadTastes() {
        tastesSubject.send(tastes)
    }
    
    func add(taste: String) {
        repository.addTaste(restaurantId: restaurantId, dishId: dishId, taste: taste)
    }
    
    func didLoadTastes() {
        repository.fetchTastes(restaurantId: restaurantId, dishId: dishId) { result in
            switch result {
            case .success(let tastes):
                self.tastes = tastes
                self.tastesSubject.send(self.tastes)
            case .failure(let error):
                print(error)
                
            }
        }
    }
    
}

extension DefaultDishDetailViewModel: DishDetailListDataSource {
    func cellForRow(at indexPath: IndexPath) -> DishDetailListItemViewModel {
        return .init(taste: tastes[indexPath.row])
    }
    
    func numberOfRowsIn(section: Int) -> Int {
        return tastes.count
    }
}
