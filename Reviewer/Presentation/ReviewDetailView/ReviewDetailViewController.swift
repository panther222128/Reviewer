//
//  ReviewDetailViewController.swift
//  Reviewer
//
//  Created by Horus on 4/14/24.
//

import UIKit
import Combine

final class ReviewDetailViewController: UIViewController {
    
    private var viewModel: ReviewDetailViewModel!
    
    private let dishListTableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.separatorInset = .init(top: 0, left: 0, bottom: 0, right: 0)
        tableView.register(ReviewDetailDishItemCell.self, forCellReuseIdentifier: "ReviewDetailDishItemCellID")
        return tableView
    }()
    
    private var reviewDetailListAdapter: ReviewDetailListAdapter?
    
    private var cancellables: Set<AnyCancellable> = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        reviewDetailListAdapter = .init(tableView: dishListTableView, dataSource: viewModel, delegate: self)
        
        viewModel.loadDishes()
    }
    
    static func create(with viewModel: ReviewDetailViewModel) -> ReviewDetailViewController {
        let viewController = ReviewDetailViewController()
        viewController.viewModel = viewModel
        return viewController
    }
    
    private func subscribe(reviewDetailListPublisher: AnyPublisher<[ReviewDetailDishItemViewModel], Never>) {
        reviewDetailListPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.dishListTableView.reloadData()
            }
            .store(in: &cancellables)
    }
    
}

extension ReviewDetailViewController: ReviewDetailListDelegate {
    func heightForRowAt() -> CGFloat {
        return 64
    }
}
