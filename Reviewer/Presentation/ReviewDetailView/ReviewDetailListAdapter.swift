//
//  ReviewDetailListAdapter.swift
//  Reviewer
//
//  Created by Horus on 4/14/24.
//

import UIKit

protocol ReviewDetailListDataSource: AnyObject {
    func cellForRow(at indexPath: IndexPath) -> ReviewDetailDishItemViewModel
    func numberOfRowsIn(section: Int) -> Int
}

protocol ReviewDetailListDelegate: AnyObject {
    func heightForRowAt() -> CGFloat
}

final class ReviewDetailListAdapter: NSObject {
    
    private var tableView: UITableView
    private weak var dataSource: ReviewDetailListDataSource?
    private weak var delegate: ReviewDetailListDelegate?
    
    init(tableView: UITableView, dataSource: ReviewDetailListDataSource?, delegate: ReviewDetailListDelegate?) {
        self.tableView = tableView
        self.dataSource = dataSource
        self.delegate = delegate
        
        super.init()
        
        tableView.dataSource = self
        tableView.delegate = self
    }
    
}

extension ReviewDetailListAdapter: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource?.numberOfRowsIn(section: section) ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ReviewDetailItemCellID", for: indexPath) as? ReviewDetailDishItemCell else { return .init() }
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

extension ReviewDetailListAdapter: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if let delegate = delegate {
            return delegate.heightForRowAt()
        } else {
            print("Delegate must be initialized.")
            return 0
        }
    }
}
