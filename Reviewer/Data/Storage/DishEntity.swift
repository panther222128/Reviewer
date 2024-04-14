//
//  DishEntity.swift
//  Reviewer
//
//  Created by Horus on 4/14/24.
//

import Foundation
import SwiftData

@Model
final class DishEntity {
    @Attribute(.unique) var id: String
    var name: String
    var date: Date = Date()
    var tastes: [String]
    
    init(id: String, name: String, tastes: [String]) {
        self.id = id
        self.name = name
        self.tastes = tastes
    }
}

extension DishEntity {
    func toDomain() -> Dish {
        return .init(id: id, name: name, date: date, tastes: tastes)
    }
}
