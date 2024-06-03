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
    var thumbnailImageData: Data? { get }
    var tastesCountPublisher: AnyPublisher<Int, Never> { get }
    
    func loadTastes()
    func loadDishName()
    func add(taste: String)
    func didLoadTastes() async throws
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
    private(set) var thumbnailImageData: Data?
    private let thumbnailImageDataSubject: CurrentValueSubject<Data?, Never>
    private var tastesCount: Int
    private let tastesCountSubject: CurrentValueSubject<Int, Never>
    
    var tastesPublisher: AnyPublisher<[String], Never> {
        return tastesSubject.eraseToAnyPublisher()
    }
    var dishNamePublisher: AnyPublisher<String, Never> {
        return dishNameSubject.eraseToAnyPublisher()
    }
    var thumbnailImageDataPublisher: AnyPublisher<Data?, Never> {
        return thumbnailImageDataSubject.eraseToAnyPublisher()
    }
    var tastesCountPublisher: AnyPublisher<Int, Never> {
        return tastesCountSubject.eraseToAnyPublisher()
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
        self.tastesCount = dish.tastes.count
        self.tastesCountSubject = .init(dish.tastes.count)
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
    
    func didLoadTastes() async throws {
        let tastes = try await repository.fetchTastes(restaurantId: restaurantId, dishId: dishId)
        self.tastes = tastes
        self.tastesCountSubject.send(self.tastes.count)
        self.tastesSubject.send(self.tastes)
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
