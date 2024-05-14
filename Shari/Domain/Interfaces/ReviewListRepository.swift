//
//  ReviewListRepository.swift
//  Reviewer
//
//  Created by Horus on 4/14/24.
//

import Foundation

protocol ReviewListRepository {
    func saveRestaurant(restairamtId: String, name: String)
    func addTaste(restaurantId: String, dishId: String, taste: String)
    func fetchRestaurants(completion: @escaping (Result<[Restaurant], Error>) -> Void)
    func deleteRestaurant(restaurantId: String)
    func deleteDish(restaurantId: String, dishId: String)
    func save(restaurantId: String, dish: Dish)
    func fetchDishes(restaurantId id: String, completion: @escaping (Result<[Dish], Error>) -> Void)
    func fetchTastes(restaurantId: String, dishId: String, completion: @escaping (Result<[String], Error>) -> Void)
    func createFile(contents: String, url: URL)
    func removeFile(url: URL)
}
