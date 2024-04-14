//
//  ReviewListStorage.swift
//  Reviewer
//
//  Created by Horus on 4/14/24.
//

import Foundation
import SwiftData

protocol ReviewListStorage {
    func saveRestaurant(with name: String)
    func fetchRestaurants(completion: @escaping ([Restaurant]?, Error?) -> Void)
    func delete(restaurant: Restaurant)
    func update(restaurant: Restaurant, dish: Dish)
    func fetchDishes(of restaurant: Restaurant, completion: @escaping ([Dish]?, Error?) -> Void)
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
    
    func saveRestaurant(with name: String) {
        if let context {
            let restaurant = RestaurantEntity(id: UUID().uuidString, name: name, date: Date())
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
    
    func delete(restaurant: Restaurant) {
        if let context, let restaurant = fetch(restaurant: restaurant) {
            context.delete(restaurant)
        } else {
            
        }
    }
    
    func update(restaurant: Restaurant, dish: Dish) {
        if let restaurant = fetch(restaurant: restaurant) {
            restaurant.dishes.append(.init(id: dish.id, name: dish.name, tastes: dish.tastes))
        } else {
            
        }
    }
    
    func fetchDishes(of restaurant: Restaurant, completion: @escaping ([Dish]?, Error?) -> Void) {
        if let restaurant = fetch(restaurant: restaurant) {
            let dishes = restaurant.dishes
            let domain = restaurant.dishes.map { $0.toDomain() }
            completion(domain, nil)
        } else {
            
        }
    }
    
    private func fetch(restaurant: Restaurant) -> RestaurantEntity? {
        let descriptor = FetchDescriptor<RestaurantEntity>(sortBy: [SortDescriptor<RestaurantEntity>(\.date)])
        if let context {
            do {
                let data = try context.fetch(descriptor)
                if let target = data.filter({ $0.id == restaurant.id }).first {
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
