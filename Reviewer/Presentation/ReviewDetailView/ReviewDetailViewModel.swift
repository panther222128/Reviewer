//
//  ReviewDetailViewModel.swift
//  Reviewer
//
//  Created by Horus on 4/14/24.
//

import Foundation

protocol ReviewDetailViewModel: ReviewDetailListDataSource {
    
}

final class DefaultReviewDetailViewModel: ReviewDetailViewModel {
    
    private let id: String
    private let dishes: [Dish]
    private let listItems: [ReviewDetailDishItemViewModel]
    
    init(id: String) {
        self.id = id
        self.dishes = []
        self.listItems = []
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
