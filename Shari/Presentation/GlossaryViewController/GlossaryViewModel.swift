//
//  GlossaryViewModel.swift
//  Reviewer
//
//  Created by Horus on 4/27/24.
//

import Foundation
import Combine

// MARK: - Boilerplate
protocol GlossaryViewModel: GlossaryListDataSource {
    var glossaryListItemsPublisher: AnyPublisher<[GlossaryListItemViewModel], Never> { get }
    
    func loadGlossaryContents()
    func didSearch(keyword: String)
}

final class DefaultGlossaryViewModel: GlossaryViewModel {
    
    private let glossaryContents: [String]
    private var glossaryListItems: [GlossaryListItemViewModel]
    private let glossaryListItemsSubject: CurrentValueSubject<[GlossaryListItemViewModel], Never>
    
    var glossaryListItemsPublisher: AnyPublisher<[GlossaryListItemViewModel], Never> {
        return glossaryListItemsSubject.eraseToAnyPublisher()
    }
    
    init() {
        self.glossaryContents = Constants.glossaryContents
        self.glossaryListItems = []
        self.glossaryListItemsSubject = .init([])
    }
    
    func loadGlossaryContents() {
        glossaryListItems = glossaryContents.map { .init(content: $0) }
        glossaryListItemsSubject.send(glossaryListItems)
    }
    
    func didSearch(keyword: String) {
        guard !keyword.isEmpty else {
            glossaryListItems = glossaryContents.map { .init(content: $0) }
            glossaryListItemsSubject.send(glossaryListItems)
            return
        }
        glossaryListItems = glossaryContents.map { .init(content: $0) }.filter { $0.content.contains(keyword) }
        glossaryListItemsSubject.send(glossaryListItems)
    }
    
}

extension DefaultGlossaryViewModel: GlossaryListDataSource {
    func cellForRow(at indexPath: IndexPath) -> GlossaryListItemViewModel {
        return glossaryListItems[indexPath.row]
    }
    
    func numberOfRowsIn(section: Int) -> Int {
        return glossaryListItems.count
    }
}
