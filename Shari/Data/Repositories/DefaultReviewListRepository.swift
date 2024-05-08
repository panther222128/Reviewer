//
//  DefaultReviewListRepository.swift
//  Reviewer
//
//  Created by Horus on 4/14/24.
//

import Foundation

final class DefaultReviewListRepository: ReviewListRepository {
    
    private let storage: ReviewListStorage
    
    init(storage: ReviewListStorage) {
        self.storage = storage
    }
    
    func saveRestaurant(restairamtId: String, name: String) {
        storage.saveRestaurant(restaurantId: restairamtId, name: name)
    }
    
    func addTaste(restaurantId: String, dishId: String, taste: String) {
        storage.addTaste(restaurantId: restaurantId, dishId: dishId, taste: taste)
    }
    
    func fetchRestaurants(completion: @escaping (Result<[Restaurant], Error>) -> Void) {
        storage.fetchRestaurants(completion: completion)
    }
    
    func deleteRestaurant(restaurantId: String) {
        storage.deleteRestaurant(restaurantId: restaurantId)
    }
    
    func deleteDish(restaurantId: String, dishId: String) {
        storage.deleteDish(restaurantId: restaurantId, dishId: dishId)
    }
    
    func save(restaurantId: String, dish: Dish) {
        storage.saveDish(restaurantId: restaurantId, dish: dish)
    }
    
    func fetchDishes(restaurantId: String, completion: @escaping (Result<[Dish], Error>) -> Void) {
        storage.fetchDishes(restaurantId: restaurantId, completion: completion)
    }
    
    func fetchTastes(restaurantId: String, dishId: String, completion: @escaping (Result<[String], Error>) -> Void) {
        storage.fetchTastes(restaurantId: restaurantId, dishId: dishId, completion: completion)
    }
    
}
