//
//  DefaultReviewListRepository.swift
//  Reviewer
//
//  Created by Horus on 4/14/24.
//

import Foundation

final class DefaultReviewListRepository: ReviewListRepository {

    private let storage: ReviewListStorage
    private let fileGenerator: FileGenerator
    
    init(storage: ReviewListStorage, fileGenerator: FileGenerator) {
        self.storage = storage
        self.fileGenerator = fileGenerator
    }
    
    func saveRestaurant(restairamtId: String, name: String) {
        storage.saveRestaurant(restaurantId: restairamtId, name: name)
    }
    
    func addTaste(restaurantId: String, dishId: String, taste: String) {
        storage.addTaste(restaurantId: restaurantId, dishId: dishId, taste: taste)
    }
    
    func fetchRestaurants() async throws -> [Restaurant] {
        let data = try await storage.fetchRestaurants()
        let domain = data.map { $0.toDomain() }
        return domain
    }
    
    func deleteRestaurant(restaurantId: String) {
        storage.deleteRestaurant(restaurantId: restaurantId)
    }
    
    func deleteDish(restaurantId: String, dishId: String) {
        storage.deleteDish(restaurantId: restaurantId, dishId: dishId)
    }
    
    func save(restaurantId: String, dish: Dish) {
        storage.saveDish(restaurantId: restaurantId, dish: dish)
    }
    
    func fetchDishes(restaurantId: String) async throws -> [Dish] {
        let data = try await storage.fetchDishes(restaurantId: restaurantId)
        let domain = data.map { $0.toDomain() }
        return domain
    }
    
    func fetchTastes(restaurantId: String, dishId: String) async throws -> [String] {
        let data = try await storage.fetchTastes(restaurantId: restaurantId, dishId: dishId)
        return data
    }
    
    func createFile(contents: String, url: URL) {
        fileGenerator.createFile(contents: contents, url: url)
    }
    
    func removeFile(url: URL) {
        fileGenerator.removeFile(url: url)
    }
    
}
