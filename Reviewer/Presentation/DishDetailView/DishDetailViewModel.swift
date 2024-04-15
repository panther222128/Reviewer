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
}

final class DefaultDishDetailViewModel: DishDetailViewModel {
    
    private let tastes: [String]
    private let tastesSubject: CurrentValueSubject<[String], Never>
    var tastesPublisher: AnyPublisher<[String], Never> {
        return tastesSubject.eraseToAnyPublisher()
    }
    
    init(tastes: [String]) {
        self.tastes = tastes
        self.tastesSubject = .init([])
    }
    
    func loadTastes() {
        tastesSubject.send(tastes)
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
