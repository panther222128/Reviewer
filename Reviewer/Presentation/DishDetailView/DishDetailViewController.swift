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
        addBarButtonItem()
        
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

extension DishDetailViewController {
    private func addBarButtonItem() {
        let barButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(didPressedAddButon))
        navigationItem.rightBarButtonItem = barButtonItem
    }
    
    @objc private func didPressedAddButon(_ sender: UIBarButtonItem) {
        let alertController = UIAlertController(title: "맛", message: nil, preferredStyle: .alert)
        alertController.addTextField()
        
        let confirmAction = UIAlertAction(title: "확인", style: .default) { _ in
            if let textFields = alertController.textFields {
                if let textField = textFields.first {
                    if let text = textField.text, !text.isEmpty {
                        self.viewModel.add(taste: text)
                        self.viewModel.didLoadTastes()
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
