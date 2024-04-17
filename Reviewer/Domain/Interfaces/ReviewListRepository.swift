//
//  ReviewListRepository.swift
//  Reviewer
//
//  Created by Horus on 4/14/24.
//

import Foundation

protocol ReviewListRepository {
    func saveRestaurant(id: String, name: String)
    func fetchRestaurants(completion: @escaping ([Restaurant]?, Error?) -> Void)
    func delete(with id: String)
    func deleteDish(dishId: String, restaurantId: String)
    func save(dish: Dish, id: String)
    func fetchDishes(with id: String, completion: @escaping ([Dish]?, Error?) -> Void)
}
