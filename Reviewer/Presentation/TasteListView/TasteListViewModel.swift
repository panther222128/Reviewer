//
//  TasteListViewModel.swift
//  Reviewer
//
//  Created by Horus on 4/11/24.
//

import Foundation
import Combine

// MARK: - Boilerplate
protocol TasteListViewModel {
    var restaurantNamePublisher: AnyPublisher<String, Never> { get }
    var tastesSectionsPublisher: AnyPublisher<[TastesSection], Never> { get }
    
    func loadTitle()
    func loadTastes()
    func didSelectTaste(at categoryIndex: Int, at index: Int)
    func didDeselectTaste(at categoryIndex: Int, at index: Int)
    func didSaveDish()
}

final class DefaultTasteListViewModel: TasteListViewModel {
    
    private let repository: ReviewListRepository
    private let restaurantId: String
    private let restaurantName: String
    private let restaurantNameSubject: CurrentValueSubject<String, Never>
    private let dishName: String
    
    private var tastesSections: [TastesSection]
    private let tastesSectionsSubject: CurrentValueSubject<[TastesSection], Never>

    var restaurantNamePublisher: AnyPublisher<String, Never> {
        return restaurantNameSubject.eraseToAnyPublisher()
    }
    var tastesSectionsPublisher: AnyPublisher<[TastesSection], Never> {
        return tastesSectionsSubject.eraseToAnyPublisher()
    }
    
    private var selectedTastes: [String]
    
    init(repository: ReviewListRepository, restaurantId: String, restaurantName: String, dishName: String) {
        self.repository = repository
        self.restaurantId = restaurantId
        self.restaurantName = restaurantName
        self.restaurantNameSubject = .init("")
        self.dishName = dishName
        self.selectedTastes = []
        self.tastesSections = Constants.tastesSections
        self.tastesSectionsSubject = .init([])
    }
    
    func loadTitle() {
        restaurantNameSubject.send(restaurantName)
    }
    
    func loadTastes() {
        tastesSectionsSubject.send(self.tastesSections)
    }
    
    func didSelectTaste(at categoryIndex: Int, at index: Int) {
        selectedTastes.append(tastesSections[categoryIndex].tastes[index])
    }
    
    func didDeselectTaste(at categoryIndex: Int, at index: Int) {
        if let firstIndex = selectedTastes.firstIndex(of: tastesSections[categoryIndex].tastes[index]) {
            selectedTastes.remove(at: firstIndex)
        } else {
            print("Cannot find selected taste.")
        }
    }
    
    func didSaveDish() {
        if !selectedTastes.isEmpty {
            repository.save(restaurantId: restaurantId, dish: .init(id: UUID().uuidString, name: dishName, date: Date(), tastes: selectedTastes))
        }
    }
    
}
