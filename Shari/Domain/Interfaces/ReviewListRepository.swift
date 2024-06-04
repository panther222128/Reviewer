//
//  ReviewListRepository.swift
//  Reviewer
//
//  Created by Horus on 4/14/24.
//

import Foundation

protocol ReviewListRepository {
    func saveRestaurant(restaurantId: String, name: String)
    func addTaste(restaurantId: String, dishId: String, taste: String)
    func fetchRestaurants() async throws -> [Restaurant]
    func deleteRestaurant(restaurantId: String)
    func deleteDish(restaurantId: String, dishId: String)
    func save(restaurantId: String, dish: Dish)
    func fetchDishes(restaurantId id: String) async throws -> [Dish]
    func fetchTastes(restaurantId: String, dishId: String) async throws -> [String]
    func createFile(contents: String, url: URL)
    func removeFile(url: URL)
}
