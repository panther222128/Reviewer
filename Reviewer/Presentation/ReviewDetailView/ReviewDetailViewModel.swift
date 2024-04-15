//
//  ReviewDetailViewModel.swift
//  Reviewer
//
//  Created by Horus on 4/14/24.
//

import Foundation
import Combine

protocol ReviewDetailViewModel: ReviewDetailListDataSource {
    var listItemsPublisher: AnyPublisher<[ReviewDetailDishItemViewModel], Never> { get }
    
    func loadDishes()
}

final class DefaultReviewDetailViewModel: ReviewDetailViewModel {
    
    private let id: String
    private var dishes: [Dish]
    private var listItems: [ReviewDetailDishItemViewModel]
    private let listItemsSubject: CurrentValueSubject<[ReviewDetailDishItemViewModel], Never>
    private let repository: ReviewListRepository
    
    var listItemsPublisher: AnyPublisher<[ReviewDetailDishItemViewModel], Never> {
        return listItemsSubject.eraseToAnyPublisher()
    }
    
    init(id: String, repository: ReviewListRepository) {
        self.id = id
        self.dishes = []
        self.listItems = []
        self.listItemsSubject = .init([])
        self.repository = repository
    }
    
    func loadDishes() {
        repository.fetchDishes(with: id) { [weak self] dishes, error in
            if let dishes {
                if let self = self {
                    self.dishes = dishes
                    self.listItems = self.dishes.map { .init(name: $0.name) }
                } else {
                    print("View model is empty.")
                }
            } else {
                print("Cannot find dishes.")
            }
        }
    }
    
}

extension DefaultReviewDetailViewModel {
    func cellForRow(at indexPath: IndexPath) -> ReviewDetailDishItemViewModel {
        return .init(name: dishes[indexPath.row].name)
    }
    
    func numberOfRowsIn(section: Int) -> Int {
        return dishes.count
    }
}
