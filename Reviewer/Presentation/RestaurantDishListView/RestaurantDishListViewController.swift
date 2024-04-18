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
        
        addSubviews()
        
        addBarButtonItem()
        
        adjustLayoutOfDishListTableView(dishListTableView: dishListTableView)
        
        reviewDetailListAdapter = .init(tableView: dishListTableView, dataSource: viewModel, delegate: self)
        
        subscribe(reviewDetailListPublisher: viewModel.listItemsPublisher)
        subscribe(restaurantNamePublisher: viewModel.restaurantNamePublisher)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        viewModel.loadTitle()
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
    
    private func subscribe(restaurantNamePublisher: AnyPublisher<String, Never>) {
        restaurantNamePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] name in
                self?.title = name
            }
            .store(in: &cancellables)
    }
    
}

extension RestaurantDishListViewController {
    private func addSubviews() {
        view.addSubview(dishListTableView)
    }
    
    private func adjustLayoutOfDishListTableView(dishListTableView: UITableView) {
        dishListTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        dishListTableView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        dishListTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        dishListTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    }
}

extension RestaurantDishListViewController {
    private func addBarButtonItem() {
        let barButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(didPressedAddButon))
        navigationItem.rightBarButtonItem = barButtonItem
    }
    
    @objc private func didPressedAddButon(_ sender: UIBarButtonItem) {
        self.viewModel.didLoadStudio()
    }
}

extension RestaurantDishListViewController: RestaurantDishListDelegate {
    func heightForRowAt() -> CGFloat {
        return 64
    }
    
    func didSelectRow(at indexPath: IndexPath) {
        viewModel.didSelectRow(at: indexPath)
    }
    
    func didTrailingSwipeForRow(at indexPath: IndexPath, tableView: UITableView) -> UISwipeActionsConfiguration {
        let deleteAction = UIContextualAction(style: .destructive, title: "삭제") { action, view, completion in
            self.presentDeleteAlert(at: indexPath)
            completion(true)
        }
        
        deleteAction.backgroundColor = .red
        
        let swipeActions = UISwipeActionsConfiguration(actions: [deleteAction])
        return swipeActions
    }
    
    private func presentDeleteAlert(at indexPath: IndexPath) {
        let alert = UIAlertController(title: "삭제", message: "삭제하시겠습니까?", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "취소", style: .cancel)
        let deleteAction = UIAlertAction(title: "삭제", style: .destructive) { _ in
            self.viewModel.didDeleteDish(at: indexPath)
            self.viewModel.loadDishes()
        }
        alert.addAction(cancelAction)
        alert.addAction(deleteAction)
        
        present(alert, animated: true)
    }
}
