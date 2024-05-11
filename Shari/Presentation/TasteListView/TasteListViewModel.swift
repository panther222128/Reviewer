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
    var dishNamePublisher: AnyPublisher<String, Never> { get }
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
    private let dishName: String
    private let dishNameSubject: CurrentValueSubject<String, Never>
    private let thumbnailImageData: Data?
    
    private var tasteCategories: [TasteCategory]
    private let tasteCategoriesSubject: CurrentValueSubject<[TasteCategory], Never>

    var dishNamePublisher: AnyPublisher<String, Never> {
        return dishNameSubject.eraseToAnyPublisher()
    }
    var tasteCategoriesPublisher: AnyPublisher<[TasteCategory], Never> {
        return tasteCategoriesSubject.eraseToAnyPublisher()
    }
    
    private var selectedTastes: [String]
    
    init(repository: ReviewListRepository, restaurantId: String, restaurantName: String, dishName: String, thumbnailImageData: Data?) {
        self.repository = repository
        self.restaurantId = restaurantId
        self.restaurantName = restaurantName
        self.dishName = dishName
        self.dishNameSubject = .init(self.dishName)
        self.thumbnailImageData = thumbnailImageData
        self.selectedTastes = []
        self.tasteCategories = Constants.tasteCategories
        self.tasteCategoriesSubject = .init([])
    }
    
    func loadTitle() {
        dishNameSubject.send(self.dishName)
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
            repository.save(restaurantId: restaurantId, dish: .init(id: UUID().uuidString, name: dishName, date: Date(), tastes: selectedTastes, thumbnailImageData: thumbnailImageData))
        }
    }
    
}
