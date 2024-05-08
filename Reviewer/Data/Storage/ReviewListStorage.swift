//
//  ReviewListStorage.swift
//  Reviewer
//
//  Created by Horus on 4/14/24.
//

import Foundation
import SwiftData

enum ReviewListStorageError: Error {
    case cannotFindRestaurants
    case cannotFindRestaurant
}

protocol ReviewListStorage {
    func saveRestaurant(restaurantId: String, name: String)
    func fetchRestaurants(completion: @escaping (Result<[Restaurant], Error>) -> Void)
    func deleteRestaurant(restaurantId: String)
    func deleteDish(restaurantId: String, dishId: String)
    func saveDish(restaurantId: String, dish: Dish)
    func fetchDishes(restaurantId: String, completion: @escaping (Result<[Dish], Error>) -> Void)
    func fetchTastes(restaurantId: String, dishId: String, completion: @escaping (Result<[String], Error>) -> Void)
    func addTaste(restaurantId: String, dishId: String, taste: String)
}

final class DefaultReviewListStorage: ReviewListStorage {
    
    private var container: ModelContainer?
    private var context: ModelContext?
    
    init() {
        do {
            container = try ModelContainer(for: RestaurantEntity.self)
            if let container {
                context = ModelContext(container)
            } else {
                print("Cannot create context.")
            }
        } catch {
            print(error)
        }
    }
    
    func saveRestaurant(restaurantId: String, name: String) {
        if let context {
            let restaurant = RestaurantEntity(id: restaurantId, name: name, date: Date())
            context.insert(restaurant)
        } else {
            print("Cannot save restaurant.")
        }
    }
    
    func fetchRestaurants(completion: @escaping (Result<[Restaurant], Error>) -> Void) {
        let descriptor = FetchDescriptor<RestaurantEntity>(sortBy: [SortDescriptor<RestaurantEntity>(\.date)])
        if let context {
            do {
                let data = try context.fetch(descriptor)
                let domain = data.map { $0.toDomain() }
                completion(.success(domain))
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    func deleteRestaurant(restaurantId: String) {
        if let context, let restaurant = fetchRestaurant(restaurantId: restaurantId) {
            context.delete(restaurant)
        } else {
            print("Cannot delete restaurant.")
        }
    }
    
    func deleteDish(restaurantId: String, dishId: String) {
        if let context, let restaurant = fetchRestaurant(restaurantId: restaurantId) {
            let dishes = restaurant.dishes
            let filteredDishes = dishes.filter { $0.id == dishId }
            filteredDishes.forEach { context.delete($0) }
            
            if let first = filteredDishes.first, let firstIndex = dishes.firstIndex(of: first) {
                restaurant.dishes.remove(at: firstIndex)
            } else {
                print("Cannot find dish.")
            }
        } else {
            print("Cannot delete dish.")
        }
    }
    
    func saveDish(restaurantId: String, dish: Dish) {
        if let restaurant = fetchRestaurant(restaurantId: restaurantId) {
            restaurant.dishes.append(.init(id: dish.id, name: dish.name, tastes: dish.tastes, thumbnailImageData: dish.thumbnailImageData))
        } else {
            print("Cannot save dish.")
        }
    }
    
    func addTaste(restaurantId: String, dishId: String, taste: String) {
        if let restaurant = fetchRestaurant(restaurantId: restaurantId) {
            let filteredDish = restaurant.dishes.filter { $0.id == dishId }
            filteredDish.forEach { $0.tastes.append(taste) }
        } else {
            print("Cannot save taste.")
        }
    }
    
    func fetchDishes(restaurantId: String, completion: @escaping (Result<[Dish], Error>) -> Void) {
        if let restaurant = fetchRestaurant(restaurantId: restaurantId) {
            let dishes = restaurant.dishes
            let domain = dishes.map { $0.toDomain() }
            completion(.success(domain))
        } else {
            print("Cannot find restaurant.")
            completion(.failure(ReviewListStorageError.cannotFindRestaurants))
        }
    }
    
    func fetchTastes(restaurantId: String, dishId: String, completion: @escaping (Result<[String], Error>) -> Void) {
        if let restaurant = fetchRestaurant(restaurantId: restaurantId) {
            let dishes = restaurant.dishes
            let filteredDishes = dishes.filter { $0.id == dishId }
            if let first = filteredDishes.first {
                completion(.success(first.tastes))
            } else {
                completion(.failure(ReviewListStorageError.cannotFindRestaurant))
            }
        } else {
            completion(.failure(ReviewListStorageError.cannotFindRestaurants))
        }
    }
    
    private func fetchRestaurant(restaurantId: String) -> RestaurantEntity? {
        let descriptor = FetchDescriptor<RestaurantEntity>(sortBy: [SortDescriptor<RestaurantEntity>(\.date)])
        if let context {
            do {
                let data = try context.fetch(descriptor)
                if let target = data.filter({ $0.id == restaurantId }).first {
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
