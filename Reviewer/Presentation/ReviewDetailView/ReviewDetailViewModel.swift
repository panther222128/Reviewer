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
    
    private let listItems: [ReviewDetailDishItemViewModel]
    
    init() {
        self.listItems = []
    }
    
}

extension DefaultReviewDetailViewModel {
    func cellForRow(at indexPath: IndexPath) -> ReviewDetailDishItemViewModel {
        return .init(name: "")
    }
    
    func numberOfRowsIn(section: Int) -> Int {
        return 0
    }
}
