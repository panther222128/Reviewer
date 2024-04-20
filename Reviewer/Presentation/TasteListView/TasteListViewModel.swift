//
//  TasteListViewModel.swift
//  Reviewer
//
//  Created by Horus on 4/11/24.
//

import Foundation
import Combine

protocol TasteListViewModel {
    var restaurantNamePublisher: AnyPublisher<String, Never> { get }
    var tastesPublisher: AnyPublisher<[String], Never> { get }
    
    func loadTitle()
    func loadTastes()
    func didSelectTaste(at index: Int)
    func didDeselectTaste(at index: Int)
    func didSaveDish()
}

final class DefaultTasteListViewModel: TasteListViewModel {
    
    private let repository: ReviewListRepository
    private let restaurantId: String
    private let restaurantName: String
    private let restaurantNameSubject: CurrentValueSubject<String, Never>
    private let dishName: String
    private let tastes: [String]
    private let tastesSubject: CurrentValueSubject<[String], Never>
    var tastesPublisher: AnyPublisher<[String], Never> {
        return tastesSubject.eraseToAnyPublisher()
    }
    var restaurantNamePublisher: AnyPublisher<String, Never> {
        return restaurantNameSubject.eraseToAnyPublisher()
    }
    
    private var selectedTastes: [String]
    
    init(repository: ReviewListRepository, restaurantId: String, restaurantName: String, dishName: String) {
        self.repository = repository
        self.restaurantId = restaurantId
        self.restaurantName = restaurantName
        self.restaurantNameSubject = .init("")
        self.dishName = dishName
        self.tastes = Constants.tastes
        self.tastesSubject = .init([])
        self.selectedTastes = []
    }
    
    func loadTitle() {
        restaurantNameSubject.send(restaurantName)
    }
    
    func loadTastes() {
        tastesSubject.send(tastes)
    }
    
    func didSelectTaste(at index: Int) {
        selectedTastes.append(tastes[index])
    }
    
    func didDeselectTaste(at index: Int) {
        if let firstIndex = selectedTastes.firstIndex(of: tastes[index]) {
            selectedTastes.remove(at: firstIndex)
        } else {
            print("Cannot find selected taste.")
        }
    }
    
    func didSaveDish() {
        if !tastes.isEmpty {
            repository.save(restaurantId: restaurantId, dish: .init(id: UUID().uuidString, name: dishName, date: Date(), tastes: selectedTastes))
        }
    }
    
}
