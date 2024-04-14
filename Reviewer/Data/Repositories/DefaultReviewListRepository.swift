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
    
    func saveRestaurant(with name: String) {
        storage.saveRestaurant(with: name)
    }
    
    func fetchRestaurants(completion: @escaping ([RestaurantEntity]?, Error?) -> Void) {
        storage.fetchRestaurants(completion: completion)
    }
    
    func delete(restaurant: RestaurantEntity) {
        storage.delete(restaurant: restaurant)
    }
    
    func update(restaurant: RestaurantEntity, dish: DishEntity) {
        storage.update(restaurant: restaurant, dish: dish)
    }
    
    func fetchDishes(of restaurant: RestaurantEntity, completion: @escaping ([DishEntity]?, Error?) -> Void) {
        storage.fetchDishes(of: restaurant, completion: completion)
    }
    
}
