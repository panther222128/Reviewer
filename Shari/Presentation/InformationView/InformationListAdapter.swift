//
//  InformationListAdapter.swift
//  Shari
//
//  Created by Horus on 6/22/24.
//

import UIKit

protocol InformationListDataSource: AnyObject {
    func numberOfRowsIn(section: Int) -> Int
    func cellForRow(at indexPath: IndexPath) -> InformationListItemViewModel
}

protocol InformationListDelegate: AnyObject {
    func didSelectItem(at indexPath: IndexPath)
    func heightForRow(at indexPath: IndexPath) -> CGFloat
}

final class InformationListAdapter: NSObject {
    
    private let tableView: UITableView
    private weak var dataSource: InformationListDataSource?
    private weak var delegate: InformationListDelegate?
    
    init(tableView: UITableView, dataSource: InformationListDataSource, delegate: InformationListDelegate) {
        self.tableView = tableView
        self.dataSource = dataSource
        self.delegate = delegate
        
        super.init()
        tableView.dataSource = self
        tableView.delegate = self
    }
    
}

extension InformationListAdapter: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let dataSource {
            return dataSource.numberOfRowsIn(section: section)
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let dataSource {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "InformationListItemCellID", for: indexPath) as? InformationListItemCell else { return .init() }
            let viewModel = dataSource.cellForRow(at: indexPath)
            cell.apply(viewModel: viewModel)
            return cell
        } else {
            return .init()
        }
    }
}

extension InformationListAdapter: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let delegate {
            delegate.didSelectItem(at: indexPath)
        } else {
            return
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if let delegate {
            return delegate.heightForRow(at: indexPath)
        } else {
            return 0
        }
    }
}
