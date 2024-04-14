//
//  ReviewListViewController.swift
//  Reviewer
//
//  Created by Horus on 4/7/24.
//

import UIKit
import Combine

final class ReviewListViewController: UIViewController {
    
    private let reviewListTableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.separatorInset = .init(top: 0, left: 0, bottom: 0, right: 0)
        return tableView
    }()
    
    private var viewModel: ReviewListViewModel!
    private var listAdapter: ReviewListAdapter?
    
    private var cancellables: Set<AnyCancellable> = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        listAdapter = .init(tableView: reviewListTableView, dataSource: viewModel, delegate: self)
        
        addSubviews()
        
        adjustLayoutOf(reviewListTableView: reviewListTableView)
        
        addBarButtonItem()
        
        subscribe(listItemViewModels: viewModel.listItemViewModelPublisher)
        
        viewModel.loadListItem()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = false
    }
    
    static func create(with viewModel: ReviewListViewModel) -> ReviewListViewController {
        let viewController = ReviewListViewController()
        viewController.viewModel = viewModel
        return viewController
    }
    
    private func subscribe(listItemViewModels: AnyPublisher<[ReviewListItemViewModel], Never>) {
        listItemViewModels
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.reviewListTableView.reloadData()
            }
            .store(in: &cancellables)
    }
    
}

extension ReviewListViewController {
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
                        self.viewModel.didPressedAlertConfirmButton(with: text)
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

extension ReviewListViewController: ReviewListDelegate {
    func heightForRowAt() -> CGFloat {
        return 80
    }
}

extension ReviewListViewController {
    private func addSubviews() {
        view.addSubview(reviewListTableView)
    }
    
    private func adjustLayoutOf(reviewListTableView: UITableView) {
        reviewListTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        reviewListTableView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        reviewListTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        reviewListTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    }
}
