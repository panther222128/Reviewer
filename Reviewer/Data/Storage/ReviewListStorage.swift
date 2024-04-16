//
//  ReviewListStorage.swift
//  Reviewer
//
//  Created by Horus on 4/14/24.
//

import Foundation
import SwiftData

protocol ReviewListStorage {
    func saveRestaurant(id: String, name: String)
    func fetchRestaurants(completion: @escaping ([Restaurant]?, Error?) -> Void)
    func delete(with id: String)
    func save(dish: Dish, id: String)
    func fetchDishes(with id: String, completion: @escaping ([Dish]?, Error?) -> Void)
}

final class DefaultReviewListStorage: ReviewListStorage {
    
    private var container: ModelContainer?
    private var context: ModelContext?
    
    init() {
        do {
            container = try ModelContainer(for: RestaurantEntity.self)
            if let container {
                context = ModelContext(container)
            }
        } catch {
            print(error)
        }
    }
    
    func saveRestaurant(id: String, name: String) {
        if let context {
            let restaurant = RestaurantEntity(id: id, name: name, date: Date())
            context.insert(restaurant)
        }
    }
    
    func fetchRestaurants(completion: @escaping ([Restaurant]?, Error?) -> Void) {
        let descriptor = FetchDescriptor<RestaurantEntity>(sortBy: [SortDescriptor<RestaurantEntity>(\.date)])
        if let context {
            do {
                let data = try context.fetch(descriptor)
                let domain = data.map { $0.toDomain() }
                completion(domain, nil)
            } catch {
                completion(nil, error)
            }
        }
    }
    
    func delete(with id: String) {
        if let context, let restaurant = fetchRestaurant(with: id) {
            context.delete(restaurant)
        } else {
            
        }
    }
    
    func save(dish: Dish, id: String) {
        if let restaurant = fetchRestaurant(with: id) {
            restaurant.dishes.append(.init(id: dish.id, name: dish.name, tastes: dish.tastes))
        } else {
            
        }
    }
    
    func fetchDishes(with id: String, completion: @escaping ([Dish]?, Error?) -> Void) {
        if let restaurant = fetchRestaurant(with: id) {
            let dishes = restaurant.dishes
            let domain = dishes.map { $0.toDomain() }
            completion(domain, nil)
        } else {
            print("Cannot find restaurant.")
            completion(nil, nil)
        }
    }
    
    private func fetchRestaurant(with id: String) -> RestaurantEntity? {
        let descriptor = FetchDescriptor<RestaurantEntity>(sortBy: [SortDescriptor<RestaurantEntity>(\.date)])
        if let context {
            do {
                let data = try context.fetch(descriptor)
                if let target = data.filter({ $0.id == id }).first {
                    return target
                } else {
                    print("Cannot find data.")
                    return nil
                }
            } catch {
                print(error)
                return nil
            }
        } else {
            print("Cannot find context.")
            return nil
        }
    }
    
}
