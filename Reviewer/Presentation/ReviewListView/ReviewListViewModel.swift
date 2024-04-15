//
//  ReviewListViewModel.swift
//  Reviewer
//
//  Created by Horus on 4/7/24.
//

import Foundation
import Combine

protocol ReviewListViewModel: ReviewListDataSource {
    var listItemViewModelPublisher: AnyPublisher<[ReviewListItemViewModel], Never> { get }
    
    func loadListItem()
    func didPressedAlertConfirmButton(with restaurantName: String)
    func didSelectItem(at indexPath: IndexPath)
}

struct ReviewListViewModelActions {
    let showStudioView: (String) -> Void
    let showReviewDetailView: (String) -> Void
}

final class DefaultReviewListViewModel: ReviewListViewModel {
    
    private let repository: ReviewListRepository
    private let actions: ReviewListViewModelActions
    private let restaurants: [Restaurant]
    private var listItemViewModels: [ReviewListItemViewModel]
    private var listItemViewModelSubject: CurrentValueSubject<[ReviewListItemViewModel], Never>
    var listItemViewModelPublisher: AnyPublisher<[ReviewListItemViewModel], Never> {
        return listItemViewModelSubject.eraseToAnyPublisher()
    }
    
    init(repository: ReviewListRepository, actions: ReviewListViewModelActions) {
        self.repository = repository
        self.actions = actions
        self.restaurants = []
        self.listItemViewModels = []
        self.listItemViewModelSubject = .init([])
    }
    
    func loadListItem() {
        listItemViewModels = []
        listItemViewModelSubject.send(listItemViewModels)
    }
    
    func didPressedAlertConfirmButton(with restaurantName: String) {
        actions.showStudioView(restaurantName)
    }
    
    func didSelectItem(at indexPath: IndexPath) {
        actions.showReviewDetailView(restaurants[indexPath.row].id)
    }
    
}

extension DefaultReviewListViewModel: ReviewListDataSource {
    func cellForRow(at indexPath: IndexPath) -> ReviewListItemViewModel {
        return listItemViewModels[indexPath.row]
    }
    
    func numberOfRowsIn(section: Int) -> Int {
        return listItemViewModels.count
    }
}
