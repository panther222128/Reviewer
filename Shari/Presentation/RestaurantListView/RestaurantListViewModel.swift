//
//  ReviewListViewModel.swift
//  Reviewer
//
//  Created by Horus on 4/7/24.
//

import Foundation
import Combine

enum SupportedFileExtension: String {
    case markdown = ".md"
    case csv = ".csv"
}

// MARK: - Boilerplate
protocol RestaurantListViewModel: RestaurantListDataSource {
    var isDeleteImmediate: Bool { get }
    var fileUrl: URL? { get }
    var createdUrls: [URL] { get }
    var listItemViewModelPublisher: AnyPublisher<[RestaurantListItemViewModel], Never> { get }
    
    func loadListItem() async throws
    func didConfirm(restaurantName: String)
    func didSelectItem(at indexPath: IndexPath)
    func didAddRestaurant(name: String)
    func didDeleteRestaurant(at indexPath: IndexPath)
    func loadIsDeleteImmediate()
    func createFile(at indexPath: IndexPath, url: URL, fileExtension: SupportedFileExtension)
    func removeFiles()
}

struct RestaurantListViewModelActions {
    let showStudioView: (_ restaurantId: String, _ restaurantName: String) -> Void
    let showRestaurantDishListView: (_ restaurantId: String, _ restaurantName: String) -> Void
}

final class DefaultRestaurantListViewModel: RestaurantListViewModel {
    
    private let repository: ReviewListRepository
    private let settingsRepository: SettingsRepository
    private let actions: RestaurantListViewModelActions
    private var restaurants: [Restaurant]
    private var restaurantId: String
    private(set) var isDeleteImmediate: Bool
    private(set) var fileUrl: URL?
    private(set) var createdUrls: [URL]
    private var listItemViewModels: [RestaurantListItemViewModel]
    private var listItemViewModelSubject: CurrentValueSubject<[RestaurantListItemViewModel], Never>
    var listItemViewModelPublisher: AnyPublisher<[RestaurantListItemViewModel], Never> {
        return listItemViewModelSubject.eraseToAnyPublisher()
    }
    
    init(repository: ReviewListRepository, settingsRepository: SettingsRepository, actions: RestaurantListViewModelActions) {
        self.repository = repository
        self.settingsRepository = settingsRepository
        self.actions = actions
        self.restaurants = []
        self.restaurantId = ""
        self.fileUrl = nil
        self.createdUrls = []
        self.isDeleteImmediate = false
        self.listItemViewModels = []
        self.listItemViewModelSubject = .init([])
    }
    
    func loadListItem() async throws {
        let restaurants = try await repository.fetchRestaurants()
        self.restaurants = restaurants.sorted(by: { $0.date < $1.date } )
        self.listItemViewModels = self.restaurants.map { .init(restaurantName: $0.name, date: $0.date) }
        self.listItemViewModelSubject.send(self.listItemViewModels)
    }
    
    func didConfirm(restaurantName: String) {
        actions.showStudioView(restaurantId, restaurantName)
    }
    
    func didSelectItem(at indexPath: IndexPath) {
        actions.showRestaurantDishListView(restaurants[indexPath.row].id, restaurants[indexPath.row].name)
    }
    
    func didAddRestaurant(name: String) {
        let id = UUID().uuidString
        restaurantId = id
        repository.saveRestaurant(restairamtId: id, name: name)
    }
    
    func didDeleteRestaurant(at indexPath: IndexPath) {
        let restaurantId = restaurants[indexPath.row].id
        repository.deleteRestaurant(restaurantId: restaurantId)
        restaurants.remove(at: indexPath.row)
    }
    
    func loadIsDeleteImmediate() {
        settingsRepository.fetchIsDeleteImmediate { [weak self] result in
            switch result {
            case .success(let isDeleteImmediate):
                self?.isDeleteImmediate = isDeleteImmediate
                
            case .failure(let failure):
                return
                
            }
        }
    }
    
    func createFile(at indexPath: IndexPath, url: URL, fileExtension: SupportedFileExtension) {
        let restaurant = restaurants[indexPath.row]
        let dishes = restaurant.dishes
        
        var contents = """
        ## \(restaurant.name)
        """
        
        for i in dishes {
            contents.append("\n")
            contents.append("\n")
            contents.append("\(i.name): \(i.tastes)")
        }
        fileUrl = url.appendingPathComponent(restaurant.date.formatYearMonthDateWithoutPoint() + restaurant.name + fileExtension.rawValue)
        if let fileUrl {
            createdUrls.append(fileUrl)
            repository.createFile(contents: contents, url: fileUrl)
        } else {
            print("Cannot find file url.")
        }
    }
    
    func removeFiles() {
        createdUrls.forEach { repository.removeFile(url: $0) }
    }
    
}

extension DefaultRestaurantListViewModel: RestaurantListDataSource {
    func cellForRow(at indexPath: IndexPath) -> RestaurantListItemViewModel {
        return listItemViewModels[indexPath.row]
    }
    
    func numberOfRowsIn(section: Int) -> Int {
        return listItemViewModels.count
    }
}
