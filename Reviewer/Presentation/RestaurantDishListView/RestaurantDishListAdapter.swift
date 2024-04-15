//
//  ReviewDetailListAdapter.swift
//  Reviewer
//
//  Created by Horus on 4/14/24.
//

import UIKit

protocol RestaurantDishListDataSource: AnyObject {
    func cellForRow(at indexPath: IndexPath) -> RestaurantDishListItemViewModel
    func numberOfRowsIn(section: Int) -> Int
}

protocol RestaurantDishListDelegate: AnyObject {
    func heightForRowAt() -> CGFloat
    func didSelectRow(at indexPath: IndexPath)
}

final class RestaurantDishListAdapter: NSObject {
    
    private var tableView: UITableView
    private weak var dataSource: RestaurantDishListDataSource?
    private weak var delegate: RestaurantDishListDelegate?
    
    init(tableView: UITableView, dataSource: RestaurantDishListDataSource?, delegate: RestaurantDishListDelegate?) {
        self.tableView = tableView
        self.dataSource = dataSource
        self.delegate = delegate
        
        super.init()
        
        tableView.dataSource = self
        tableView.delegate = self
    }
    
}

extension RestaurantDishListAdapter: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource?.numberOfRowsIn(section: section) ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ReviewDetailItemCellID", for: indexPath) as? RestaurantDishListItemCell else { return .init() }
        if let dataSource {
            let viewModel = dataSource.cellForRow(at: indexPath)
            cell.apply(viewModel: viewModel)
            return cell
        } else {
            print("Cannot find data source.")
            return .init()
        }
    }
}

extension RestaurantDishListAdapter: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if let delegate = delegate {
            return delegate.heightForRowAt()
        } else {
            print("Delegate must be initialized.")
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let delegate = delegate {
            delegate.didSelectRow(at: indexPath)
        } else {
            print("Delegate must be initialized.")
        }
    }
}
