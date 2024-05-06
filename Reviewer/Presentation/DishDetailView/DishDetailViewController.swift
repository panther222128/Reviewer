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
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        return scrollView
    }()
    private let containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    private let thumbnailImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    private let dishDetailListTableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(DishDetailListItemCell.self, forCellReuseIdentifier: "DishDetailListItemCellID")
        tableView.separatorInset = .init(top: 0, left: 0, bottom: 0, right: 0)
        tableView.showsVerticalScrollIndicator = false
        tableView.showsHorizontalScrollIndicator = false
        tableView.isScrollEnabled = false
        return tableView
    }()
    
    private var listAdapter: DishDetailListAdapter?
    
    private var cancellabes: Set<AnyCancellable> = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        listAdapter = .init(tableView: dishDetailListTableView, dataSource: viewModel, delegate: self)
        
        addSubviews()
        adjustLayoutOf(scrollView: scrollView)
        adjustLayoutOf(containerView: containerView)
        adjustLayoutOf(thumbnailImageView: thumbnailImageView)
        adjustLayoutOf(dishDetailListTableView: dishDetailListTableView)
        
        addBarButtonItem()
        
        subscribe(thumbnailImageDataPublisher: viewModel.thumbnailImageDataPublisher)
        subscribe(tastesPublisher: viewModel.tastesPublisher)
        subscribe(dishNamePublisher: viewModel.dishNamePublisher)
        
        viewModel.loadTastes()
        viewModel.loadDishName()
        viewModel.loadThumbnailImage()
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
    
    private func subscribe(dishNamePublisher: AnyPublisher<String, Never>) {
        dishNamePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] dishName in
                self?.title = dishName
            }
            .store(in: &cancellabes)
    }
    
    private func subscribe(thumbnailImageDataPublisher: AnyPublisher<Data?, Never>) {
        thumbnailImageDataPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] thumbnailImageData in
                guard let self = self else { return }
                if let thumbnailImageData {
                    self.thumbnailImageView.image = UIImage(data: thumbnailImageData)
                } else {
                    print("Thumbnail image is empty.")
                }
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
        
        let cancelAction = UIAlertAction(title: "취소", style: .destructive, handler: nil)
        alertController.addAction(cancelAction)
        
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
        view.addSubview(scrollView)
        scrollView.addSubview(containerView)
        containerView.addSubview(thumbnailImageView)
        containerView.addSubview(dishDetailListTableView)
    }
    
    private func adjustLayoutOf(scrollView: UIScrollView) {
        scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        scrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
        scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
    }
    
    private func adjustLayoutOf(containerView: UIView) {
        let frameLayout = scrollView.frameLayoutGuide
        let contentLayout = scrollView.contentLayoutGuide
        
        containerView.leadingAnchor.constraint(equalTo: contentLayout.leadingAnchor).isActive = true
        containerView.topAnchor.constraint(equalTo: contentLayout.topAnchor).isActive = true
        containerView.trailingAnchor.constraint(equalTo: contentLayout.trailingAnchor).isActive = true
        containerView.bottomAnchor.constraint(equalTo: contentLayout.bottomAnchor).isActive = true
        
        containerView.leadingAnchor.constraint(equalTo: frameLayout.leadingAnchor).isActive = true
        containerView.trailingAnchor.constraint(equalTo: frameLayout.trailingAnchor).isActive = true
    }
    
    private func adjustLayoutOf(thumbnailImageView: UIImageView) {
        thumbnailImageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor).isActive = true
        thumbnailImageView.topAnchor.constraint(equalTo: containerView.topAnchor).isActive = true
        thumbnailImageView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor).isActive = true
        thumbnailImageView.bottomAnchor.constraint(equalTo: dishDetailListTableView.topAnchor).isActive = true
        thumbnailImageView.heightAnchor.constraint(equalTo: thumbnailImageView.widthAnchor, multiplier: 4/3).isActive = true
    }
    
    private func adjustLayoutOf(dishDetailListTableView: UITableView) {
        dishDetailListTableView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor).isActive = true
        dishDetailListTableView.topAnchor.constraint(equalTo: thumbnailImageView.bottomAnchor).isActive = true
        dishDetailListTableView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor).isActive = true
        dishDetailListTableView.bottomAnchor.constraint(equalTo: containerView.safeAreaLayoutGuide.bottomAnchor).isActive = true
        dishDetailListTableView.heightAnchor.constraint(greaterThanOrEqualToConstant: CGFloat(viewModel.tastesCount * 64)).isActive = true
    }
}
