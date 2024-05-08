//
//  DishDetailListAdapter.swift
//  Reviewer
//
//  Created by Jun Ho JANG on 4/15/24.
//

import UIKit

protocol DishDetailListDataSource: AnyObject {
    func cellForRow(at indexPath: IndexPath) -> DishDetailListItemViewModel
    func numberOfRowsIn(section: Int) -> Int
}

protocol DishDetailListDelegate: AnyObject {
    func heightForRow(at indexPath: IndexPath) -> CGFloat
}

final class DishDetailListAdapter: NSObject {
    
    private let tableView: UITableView
    private weak var dataSource: DishDetailListDataSource?
    private weak var delegate: DishDetailListDelegate?
    
    init(tableView: UITableView, dataSource: DishDetailListDataSource?, delegate: DishDetailListDelegate?) {
        self.tableView = tableView
        self.dataSource = dataSource
        self.delegate = delegate
        
        super.init()
        
        tableView.dataSource = self
        tableView.delegate = self
    }
    
}

extension DishDetailListAdapter: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let dataSource {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "DishDetailListItemCellID", for: indexPath) as? DishDetailListItemCell else { return .init() }
            let viewModel = dataSource.cellForRow(at: indexPath)
            cell.apply(viewModel: viewModel)
            return cell
        } else {
            print("Cannot find data source.")
            return .init()
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let dataSource {
            return dataSource.numberOfRowsIn(section: section)
        } else {
            print("Cannot find data source.")
            return 0
        }
    }
}

extension DishDetailListAdapter: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if let delegate {
            return delegate.heightForRow(at: indexPath)
        } else {
            print("Cannot find delegate.")
            return 0
        }
    }
}
