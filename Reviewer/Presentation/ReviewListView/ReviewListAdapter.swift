//
//  ReviewListAdapter.swift
//  Reviewer
//
//  Created by Horus on 4/10/24.
//

import UIKit

protocol ReviewListDataSource: AnyObject {
    func cellForRow(at indexPath: IndexPath) -> ReviewListItemViewModel
    func numberOfRowsIn(section: Int) -> Int
}

protocol ReviewListDelegate: AnyObject {
    func heightForRowAt() -> CGFloat
    func didSelectItem(at indexPath: IndexPath)
}

final class ReviewListAdapter: NSObject {
    
    private let tableView: UITableView
    private weak var dataSource: ReviewListDataSource?
    private weak var delegate: ReviewListDelegate?
    
    init(tableView: UITableView, dataSource: ReviewListDataSource?, delegate: ReviewListDelegate?) {
        tableView.register(ReviewListItemCell.self, forCellReuseIdentifier: "ReviewListItemCellID")
        self.tableView = tableView
        self.dataSource = dataSource
        self.delegate = delegate
        super.init()
        
        self.tableView.dataSource = self
        self.tableView.delegate = self
    }
    
}

extension ReviewListAdapter: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ReviewListItemCellID", for: indexPath) as? ReviewListItemCell else {
            print("Datasource must be initialized.")
            return .init()
        }
        if let dataSource = dataSource {
            cell.apply(reviewListItemViewModel: dataSource.cellForRow(at: indexPath))
            return cell
        } else {
            print("Datasource must be initialized.")
            return .init()
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let dataSource = dataSource {
            return dataSource.numberOfRowsIn(section: section)
        } else {
            print("Datasource must be initialized.")
            return 0
        }
    }
}

extension ReviewListAdapter: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if let delegate {
            return delegate.heightForRowAt()
        } else {
            print("Delegate must be initialized.")
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let delegate {
            delegate.didSelectItem(at: indexPath)
        } else {
            print("Cannot find delegate.")
        }
    }
}
