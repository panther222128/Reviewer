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
    var thumbnailImageData: Data?
    
    init(id: String, name: String, tastes: [String], thumbnailImageData: Data?) {
        self.id = id
        self.name = name
        self.tastes = tastes
        self.thumbnailImageData = thumbnailImageData
    }
}

extension DishEntity {
    func toDomain() -> Dish {
        return .init(id: id, name: name, date: date, tastes: tastes, thumbnailImageData: thumbnailImageData)
    }
}
