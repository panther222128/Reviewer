//
//  ReviewDetailViewController.swift
//  Reviewer
//
//  Created by Horus on 4/14/24.
//

import UIKit
import Combine

final class RestaurantDishListViewController: UIViewController {
    
    private var viewModel: RestaurantDishListViewModel!
    
    private let dishListTableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.separatorInset = .init(top: 0, left: 0, bottom: 0, right: 0)
        tableView.register(RestaurantDishListItemCell.self, forCellReuseIdentifier: "ReviewDetailDishItemCellID")
        return tableView
    }()
    
    private var reviewDetailListAdapter: RestaurantDishListAdapter?
    
    private var cancellables: Set<AnyCancellable> = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        reviewDetailListAdapter = .init(tableView: dishListTableView, dataSource: viewModel, delegate: self)
        
        viewModel.loadDishes()
    }
    
    static func create(with viewModel: RestaurantDishListViewModel) -> RestaurantDishListViewController {
        let viewController = RestaurantDishListViewController()
        viewController.viewModel = viewModel
        return viewController
    }
    
    private func subscribe(reviewDetailListPublisher: AnyPublisher<[RestaurantDishListItemViewModel], Never>) {
        reviewDetailListPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.dishListTableView.reloadData()
            }
            .store(in: &cancellables)
    }
    
}

extension RestaurantDishListViewController: RestaurantDishListDelegate {
    func heightForRowAt() -> CGFloat {
        return 64
    }
    
    func didSelectRow(at indexPath: IndexPath) {
        viewModel.didSelectRow(at: indexPath)
    }
}
