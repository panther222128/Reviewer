//
//  DishDetailViewModel.swift
//  Reviewer
//
//  Created by Jun Ho JANG on 4/15/24.
//

import Foundation
import Combine

// MARK: - Boilerplate
protocol DishDetailViewModel: DishDetailListDataSource {
    var tastesPublisher: AnyPublisher<[String], Never> { get }
    var dishNamePublisher: AnyPublisher<String, Never> { get }
    var thumbnailImageDataPublisher: AnyPublisher<Data?, Never> { get }
    var tastesCount: Int { get }
    
    func loadTastes()
    func loadDishName()
    func add(taste: String)
    func didLoadTastes()
    func loadThumbnailImage()
}

final class DefaultDishDetailViewModel: DishDetailViewModel {
    
    private let repository: ReviewListRepository
    private let restaurantId: String
    private let dishId: String
    private var tastes: [String]
    private let tastesSubject: CurrentValueSubject<[String], Never>
    private let dishName: String
    private let dishNameSubject: CurrentValueSubject<String, Never>
    private let thumbnailImageData: Data?
    private let thumbnailImageDataSubject: CurrentValueSubject<Data?, Never>
    private(set) var tastesCount: Int
    
    var tastesPublisher: AnyPublisher<[String], Never> {
        return tastesSubject.eraseToAnyPublisher()
    }
    var dishNamePublisher: AnyPublisher<String, Never> {
        return dishNameSubject.eraseToAnyPublisher()
    }
    var thumbnailImageDataPublisher: AnyPublisher<Data?, Never> {
        return thumbnailImageDataSubject.eraseToAnyPublisher()
    }
    
    init(repository: ReviewListRepository, restaurantId: String, dish: Dish) {
        self.repository = repository
        self.restaurantId = restaurantId
        self.dishId = dish.id
        self.tastes = dish.tastes
        self.tastesSubject = .init(dish.tastes)
        self.dishName = dish.name
        self.dishNameSubject = .init(dish.name)
        self.thumbnailImageData = dish.thumbnailImageData
        self.thumbnailImageDataSubject = .init(dish.thumbnailImageData)
        self.tastesCount = tastes.count
    }
    
    func loadTastes() {
        tastesSubject.send(tastes)
    }
    
    func loadDishName() {
        dishNameSubject.send(dishName)
    }
    
    func loadThumbnailImage() {
        thumbnailImageDataSubject.send(thumbnailImageData)
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
