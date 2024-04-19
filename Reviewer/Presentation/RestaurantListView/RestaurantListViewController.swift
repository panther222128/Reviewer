//
//  ReviewListViewController.swift
//  Reviewer
//
//  Created by Horus on 4/7/24.
//

import UIKit
import Combine

final class RestaurantListViewController: UIViewController {
    
    private let restaurantListTableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(RestaurantListItemCell.self, forCellReuseIdentifier: "RestaurantListItemCellID")
        tableView.separatorInset = .init(top: 0, left: 0, bottom: 0, right: 0)
        return tableView
    }()
    
    private var viewModel: RestaurantListViewModel!
    private var listAdapter: RestaurantListAdapter?
    
    private var cancellables: Set<AnyCancellable> = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        listAdapter = .init(tableView: restaurantListTableView, dataSource: viewModel, delegate: self)
        
        addSubviews()
        
        adjustLayoutOf(restaurantListTableView: restaurantListTableView)
        
        addBarButtonItem()
        
        subscribe(listItemViewModels: viewModel.listItemViewModelPublisher)
        
        viewModel.loadListItem()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = false
        
        viewModel.loadIsDeleteImmediate()
    }
    
    static func create(with viewModel: RestaurantListViewModel) -> RestaurantListViewController {
        let viewController = RestaurantListViewController()
        viewController.viewModel = viewModel
        return viewController
    }
    
    private func subscribe(listItemViewModels: AnyPublisher<[RestaurantListItemViewModel], Never>) {
        listItemViewModels
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.restaurantListTableView.reloadData()
            }
            .store(in: &cancellables)
    }
    
}

extension RestaurantListViewController {
    private func addBarButtonItem() {
        let barButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(didPressedAddButon))
        navigationItem.rightBarButtonItem = barButtonItem
    }
    
    @objc private func didPressedAddButon(_ sender: UIBarButtonItem) {
        let alertController = UIAlertController(title: "오마카세 이름", message: nil, preferredStyle: .alert)
        alertController.addTextField()
        
        let confirmAction = UIAlertAction(title: "확인", style: .default) { _ in
            if let textFields = alertController.textFields {
                if let textField = textFields.first {
                    if let text = textField.text, !text.isEmpty {
                        self.viewModel.didAddRestaurant(name: text)
                        self.viewModel.didPressedAlertConfirmButton(with: text)
                        self.viewModel.loadListItem()
                    } else {
                        print("Text must not be empty.")
                    }
                } else {
                    print("Cannot find text field.")
                }
            }
        }
        alertController.addAction(confirmAction)
        
        let cancelAction = UIAlertAction(title: "취소", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true, completion: nil)
    }
}

extension RestaurantListViewController: RestaurantListDelegate {
    func heightForRowAt() -> CGFloat {
        return 80
    }
    
    func didSelectItem(at indexPath: IndexPath) {
        viewModel.didSelectItem(at: indexPath)
    }
    
    func didTrailingSwipeForRow(at indexPath: IndexPath, tableView: UITableView) -> UISwipeActionsConfiguration {
        let deleteAction = UIContextualAction(style: .destructive, title: "삭제") { action, view, completion in
            if self.viewModel.isDeleteImmediate {
                self.viewModel.didDeleteRestaurant(at: indexPath)
                self.viewModel.loadListItem()
            } else {
                self.presentDeleteAlert(at: indexPath)
            }
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
            self.viewModel.didDeleteRestaurant(at: indexPath)
            self.viewModel.loadListItem()
        }
        alert.addAction(cancelAction)
        alert.addAction(deleteAction)
        
        present(alert, animated: true)
    }
}

extension RestaurantListViewController {
    private func addSubviews() {
        view.addSubview(restaurantListTableView)
    }
    
    private func adjustLayoutOf(restaurantListTableView: UITableView) {
        restaurantListTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        restaurantListTableView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        restaurantListTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        restaurantListTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    }
}
