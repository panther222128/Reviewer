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
    
    func saveRestaurant(id: String, name: String) {
        storage.saveRestaurant(id: id, name: name)
    }
    
    func fetchRestaurants(completion: @escaping ([Restaurant]?, Error?) -> Void) {
        storage.fetchRestaurants(completion: completion)
    }
    
    func delete(with id: String) {
        storage.delete(with: id)
    }
    
    func deleteDish(dishId: String, restaurantId: String) {
        storage.deleteDish(dishId: dishId, restaurantId: restaurantId)
    }
    
    func save(dish: Dish, id: String) {
        storage.save(dish: dish, id: id)
    }
    
    func fetchDishes(with id: String, completion: @escaping ([Dish]?, Error?) -> Void) {
        storage.fetchDishes(with: id, completion: completion)
    }
    
}
