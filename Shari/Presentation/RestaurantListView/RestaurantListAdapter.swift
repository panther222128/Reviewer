//
//  ReviewListAdapter.swift
//  Reviewer
//
//  Created by Horus on 4/10/24.
//

import UIKit

protocol RestaurantListDataSource: AnyObject {
    func cellForRow(at indexPath: IndexPath) -> RestaurantListItemViewModel
    func numberOfRowsIn(section: Int) -> Int
}

protocol RestaurantListDelegate: AnyObject {
    func heightForRowAt() -> CGFloat
    func didSelectItem(at indexPath: IndexPath)
    func didTrailingSwipeForRow(at indexPath: IndexPath, tableView: UITableView) -> UISwipeActionsConfiguration
    func didLoadContextMenu(at indexPath: IndexPath) -> UIContextMenuConfiguration?
}

final class RestaurantListAdapter: NSObject {
    
    private let tableView: UITableView
    private weak var dataSource: RestaurantListDataSource?
    private weak var delegate: RestaurantListDelegate?
    
    init(tableView: UITableView, dataSource: RestaurantListDataSource?, delegate: RestaurantListDelegate?) {
        tableView.register(RestaurantListItemCell.self, forCellReuseIdentifier: "ReviewListItemCellID")
        self.tableView = tableView
        self.dataSource = dataSource
        self.delegate = delegate
        super.init()
        
        self.tableView.dataSource = self
        self.tableView.delegate = self
    }
    
}

extension RestaurantListAdapter: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "RestaurantListItemCellID", for: indexPath) as? RestaurantListItemCell else {
            print("Data source must be initialized.")
            return .init()
        }
        if let dataSource {
            cell.apply(reviewListItemViewModel: dataSource.cellForRow(at: indexPath))
            return cell
        } else {
            print("Data source must be initialized.")
            return .init()
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let dataSource {
            return dataSource.numberOfRowsIn(section: section)
        } else {
            print("Data source must be initialized.")
            return 0
        }
    }
}

extension RestaurantListAdapter: UITableViewDelegate {
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
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        if let delegate {
            return delegate.didTrailingSwipeForRow(at: indexPath, tableView: tableView)
        } else {
            print("Cannot find delegate.")
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        if let delegate {
            return delegate.didLoadContextMenu(at: indexPath)
        } else {
            print("Cannot find delegate.")
            return nil
        }
    }
}
