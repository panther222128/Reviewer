//
//  InformationViewModel.swift
//  Shari
//
//  Created by Horus on 6/22/24.
//

import Foundation
import Combine

protocol InformationViewModel: InformationListDataSource {
    var listItemsPublisher: AnyPublisher<[InformationListItemViewModel], Never> { get }
    
    func load()
    func didLoadInformationDetail(at indexPath: IndexPath)
}

struct InformationViewModelActions {
    let showInformationDetailView: (Information) -> Void
}

final class DefaultInformationViewModel: InformationViewModel {
    
    private let actions: InformationViewModelActions
    private let information: [Information]
    private var listItems: [InformationListItemViewModel]
    private let listItemsSubject: CurrentValueSubject<[InformationListItemViewModel], Never>
    var listItemsPublisher: AnyPublisher<[InformationListItemViewModel], Never> {
        return listItemsSubject.eraseToAnyPublisher()
    }
    
    init(actions: InformationViewModelActions) {
        self.actions = actions
        self.information = [.init(title: "오마카세를 즐기는 작은 팁 몇 가지", url: URL(string: "https://blog.naver.com/fzfalert/223471019145"))]
        self.listItems = []
        self.listItemsSubject = .init([])
    }
    
    func load() {
        listItems = information.map { .init(information: $0) }
        listItemsSubject.send(listItems)
    }
    
    func didLoadInformationDetail(at indexPath: IndexPath) {
        let information = information[indexPath.row]
        actions.showInformationDetailView(information)
    }
    
}

extension DefaultInformationViewModel: InformationListDataSource {
    func cellForRow(at indexPath: IndexPath) -> InformationListItemViewModel {
        return listItemsSubject.value[indexPath.row]
    }
    
    func numberOfRowsIn(section: Int) -> Int {
        return listItemsSubject.value.count
    }
}
