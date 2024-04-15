//
//  RestaurantEntity.swift
//  Reviewer
//
//  Created by Horus on 4/14/24.
//

import Foundation
import SwiftData

@Model
final class RestaurantEntity {
    @Attribute(.unique) var id: String
    var name: String
    var date: Date
    @Relationship(deleteRule: .cascade)
    var dishes: [DishEntity] = []
    
    init(id: String, name: String, date: Date) {
        self.id = id
        self.name = name
        self.date = date
    }
}

extension RestaurantEntity {
    func toDomain() -> Restaurant {
        return .init(id: id, name: name, date: date, dishes: dishes.map { $0.toDomain() })
    }
}
