//
//  InformationViewController.swift
//  Shari
//
//  Created by Horus on 6/22/24.
//

import UIKit
import Combine

final class InformationViewController: UIViewController {
    
    private let informationListTableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(InformationListItemCell.self, forCellReuseIdentifier: "InformationListItemCellID")
        tableView.separatorInset = .init(top: 0, left: 0, bottom: 0, right: 0)
        tableView.showsVerticalScrollIndicator = false
        tableView.showsHorizontalScrollIndicator = false
        return tableView
    }()
    
    private var informationListAdapter: InformationListAdapter?
    private var viewModel: InformationViewModel!
    private var cancellables: Set<AnyCancellable> = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        addSubviews()
        adjustLayoutOf(informationListTableView: informationListTableView)
        
        informationListAdapter = .init(tableView: informationListTableView, dataSource: viewModel, delegate: self)
        
        subscribe(listItemsPublisher: viewModel.listItemsPublisher)
        
        viewModel.load()
    }
    
    static func create(with viewModel: InformationViewModel) -> InformationViewController {
        let viewController = InformationViewController()
        viewController.viewModel = viewModel
        return viewController
    }
    
    private func subscribe(listItemsPublisher: AnyPublisher<[InformationListItemViewModel], Never>) {
        listItemsPublisher
            .sink { [weak self] _ in
                self?.informationListTableView.reloadData()
            }
            .store(in: &cancellables)
    }
    
}

extension InformationViewController {
    private func addSubviews() {
        view.addSubview(informationListTableView)
    }
    
    private func adjustLayoutOf(informationListTableView: UITableView) {
        informationListTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        informationListTableView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        informationListTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        informationListTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    }
}

extension InformationViewController: InformationListDelegate {
    func didSelectItem(at indexPath: IndexPath) {
        viewModel.didLoadInformationDetail(at: indexPath)
    }
    
    func heightForRow(at indexPath: IndexPath) -> CGFloat {
        return 80
    }
}
