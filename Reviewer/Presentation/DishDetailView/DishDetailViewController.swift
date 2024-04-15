//
//  DishDetailViewController.swift
//  Reviewer
//
//  Created by Jun Ho JANG on 4/15/24.
//

import UIKit
import Combine

final class DishDetailViewController: UIViewController {
    
    private var viewModel: DishDetailViewModel!
    
    private let dishDetailListTableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(DishDetailListItemCell.self, forCellReuseIdentifier: "DishDetailListItemCellID")
        return tableView
    }()
    
    private var listAdapter: DishDetailListAdapter?
    
    private var cancellabes: Set<AnyCancellable> = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        listAdapter = .init(tableView: dishDetailListTableView, dataSource: viewModel, delegate: self)
        
        addSubviews()
        adjustLayoutOf(dishDetailListTableView: dishDetailListTableView)
        
        subscribe(tastesPublisher: viewModel.tastesPublisher)
        
        viewModel.loadTastes()
    }
    
    static func create(with viewModel: DishDetailViewModel) -> DishDetailViewController {
        let viewController = DishDetailViewController()
        viewController.viewModel = viewModel
        return viewController
    }
    
    private func subscribe(tastesPublisher: AnyPublisher<[String], Never>) {
        tastesPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.dishDetailListTableView.reloadData()
            }
            .store(in: &cancellabes)
    }
    
}

extension DishDetailViewController: DishDetailListDelegate {
    func heightForRow(at indexPath: IndexPath) -> CGFloat {
        return 64
    }
}

extension DishDetailViewController {
    private func addSubviews() {
        view.addSubview(dishDetailListTableView)
    }
    
    private func adjustLayoutOf(dishDetailListTableView: UITableView) {
        dishDetailListTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        dishDetailListTableView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        dishDetailListTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        dishDetailListTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    }
}
