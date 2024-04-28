//
//  GlossaryViewController.swift
//  Reviewer
//
//  Created by Horus on 4/27/24.
//

import UIKit
import Combine

final class GlossaryViewController: UIViewController {
    
    private var viewModel: GlossaryViewModel!
    
    private let glossarySearchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        return searchBar
    }()
    private let glossaryListTableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(GlossaryListItemCell.self, forCellReuseIdentifier: "GlossaryListItemCellID")
        tableView.separatorInset = .init(top: 0, left: 0, bottom: 0, right: 0)
        tableView.showsVerticalScrollIndicator = false
        tableView.showsHorizontalScrollIndicator = false
        return tableView
    }()
    
    private var listAdapter: GlossaryListAdapter?
    
    private var cancellables: Set<AnyCancellable> = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        listAdapter = .init(tableView: glossaryListTableView, dataSource: viewModel, delegate: self)
        
        addSubviews()
        adjustLayoutOf(glossarySearchBar: glossarySearchBar)
        adjustLayoutOf(glossaryListTableView: glossaryListTableView)
        
        subscribe(glossaryListItemsPublisher: viewModel.glossaryListItemsPublisher)
        
        glossarySearchBar.delegate = self
        
        viewModel.loadGlossaryContents()
    }
    
    static func create(with viewModel: GlossaryViewModel) -> GlossaryViewController {
        let viewController = GlossaryViewController()
        viewController.viewModel = viewModel
        return viewController
    }
    
    private func subscribe(glossaryListItemsPublisher: AnyPublisher<[GlossaryListItemViewModel], Never>) {
        glossaryListItemsPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.glossaryListTableView.reloadData()
            }
            .store(in: &cancellables)
    }
    
}

extension GlossaryViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        viewModel.didSearch(keyword: searchText)
    }
}

extension GlossaryViewController: GlossaryListDelegate {
    func heightForRow(at indexPath: IndexPath) -> CGFloat {
        return 64
    }
}

extension GlossaryViewController {
    private func addSubviews() {
        view.addSubview(glossarySearchBar)
        view.addSubview(glossaryListTableView)
    }
    
    private func adjustLayoutOf(glossarySearchBar: UISearchBar) {
        glossarySearchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        glossarySearchBar.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        glossarySearchBar.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
    }
    
    private func adjustLayoutOf(glossaryListTableView: UITableView) {
        glossaryListTableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        glossaryListTableView.topAnchor.constraint(equalTo: glossarySearchBar.bottomAnchor).isActive = true
        glossaryListTableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
        glossaryListTableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        
    }
}
