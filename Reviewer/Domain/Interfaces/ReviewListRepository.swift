//
//  ReviewListRepository.swift
//  Reviewer
//
//  Created by Horus on 4/14/24.
//

import Foundation

protocol ReviewListRepository {
    func saveRestaurant(with name: String)
    func fetchRestaurants(completion: @escaping ([Restaurant]?, Error?) -> Void)
    func delete(with id: String)
    func update(with id: String, dish: Dish)
    func fetchDishes(with id: String, completion: @escaping ([Dish]?, Error?) -> Void)
}
