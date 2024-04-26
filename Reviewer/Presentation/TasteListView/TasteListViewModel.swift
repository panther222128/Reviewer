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
    var tasteCategoriesPublisher: AnyPublisher<[TasteCategory], Never> { get }
    
    func loadTitle()
    func loadTasteCategories()
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
    
    private var tasteCategories: [TasteCategory]
    private let tasteCategoriesSubject: CurrentValueSubject<[TasteCategory], Never>

    var restaurantNamePublisher: AnyPublisher<String, Never> {
        return restaurantNameSubject.eraseToAnyPublisher()
    }
    var tasteCategoriesPublisher: AnyPublisher<[TasteCategory], Never> {
        return tasteCategoriesSubject.eraseToAnyPublisher()
    }
    
    private var selectedTastes: [String]
    
    init(repository: ReviewListRepository, restaurantId: String, restaurantName: String, dishName: String) {
        self.repository = repository
        self.restaurantId = restaurantId
        self.restaurantName = restaurantName
        self.restaurantNameSubject = .init("")
        self.dishName = dishName
        self.selectedTastes = []
        self.tasteCategories = Constants.tasteCategories
        self.tasteCategoriesSubject = .init([])
    }
    
    func loadTitle() {
        restaurantNameSubject.send(restaurantName)
    }
    
    func loadTasteCategories() {
        tasteCategoriesSubject.send(self.tasteCategories)
    }
    
    func didSelectTaste(at categoryIndex: Int, at index: Int) {
        selectedTastes.append(tasteCategories[categoryIndex].tastes[index])
    }
    
    func didDeselectTaste(at categoryIndex: Int, at index: Int) {
        if let firstIndex = selectedTastes.firstIndex(of: tasteCategories[categoryIndex].tastes[index]) {
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
