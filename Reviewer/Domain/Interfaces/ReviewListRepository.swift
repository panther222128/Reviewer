//
//  ReviewListRepository.swift
//  Reviewer
//
//  Created by Horus on 4/14/24.
//

import Foundation

protocol ReviewListRepository {
    func saveRestaurant(id: String, name: String)
    func addTaste(restaurantId: String, dishId: String, taste: String)
    func fetchRestaurants(completion: @escaping (Result<[Restaurant], Error>) -> Void)
    func delete(with id: String)
    func deleteDish(dishId: String, restaurantId: String)
    func save(dish: Dish, id: String)
    func fetchDishes(with id: String, completion: @escaping (Result<[Dish], Error>) -> Void)
    func fetchTastes(restaurantId: String, dishId: String, completion: @escaping (Result<[String], Error>) -> Void)
}
