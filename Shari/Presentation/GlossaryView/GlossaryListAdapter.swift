//
//  GlossaryListAdapter.swift
//  Reviewer
//
//  Created by Horus on 4/27/24.
//

import UIKit

protocol GlossaryListDataSource: AnyObject {
    func cellForRow(at indexPath: IndexPath) -> GlossaryListItemViewModel
    func numberOfRowsIn(section: Int) -> Int
}

protocol GlossaryListDelegate: AnyObject {
    func heightForRow(at indexPath: IndexPath) -> CGFloat
    func scrollViewWillBeginDragging()
}

final class GlossaryListAdapter: NSObject {
    
    private let tableView: UITableView
    private weak var dataSource: GlossaryListDataSource?
    private weak var delegate: GlossaryListDelegate?
    
    init(tableView: UITableView, dataSource: GlossaryListDataSource, delegate: GlossaryListDelegate) {
        self.tableView = tableView
        self.dataSource = dataSource
        self.delegate = delegate
        
        super.init()
        
        self.tableView.dataSource = self
        self.tableView.delegate = self
    }
    
}

extension GlossaryListAdapter: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "GlossaryListItemCellID", for: indexPath) as? GlossaryListItemCell else { return .init() }
        if let dataSource {
            cell.apply(viewModel: dataSource.cellForRow(at: indexPath))
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

extension GlossaryListAdapter: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if let delegate {
            return delegate.heightForRow(at: indexPath)
        } else {
            print("Delegate must be initialized.")
            return 0
        }
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        if let delegate {
            delegate.scrollViewWillBeginDragging()
        } else {
            print("Delegate must be initialized.")
        }
    }
}
