//
//  TasteListViewController.swift
//  Reviewer
//
//  Created by Horus on 4/11/24.
//

import UIKit
import Combine

final class TasteListViewController: UIViewController {
    
    private var viewModel: TasteListViewModel!
    
    private let containerScrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        return scrollView
    }()
    private let containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    private let tasteListStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        return stackView
    }()
    
    private var cancellables: Set<AnyCancellable> = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        addSubviews()
        adjustLayoutOf(containerScrollView: containerScrollView)
        adjustLayoutOf(containerView: containerView)
        adjustLayoutOf(tasteListStackView: tasteListStackView)
        
        addBarButtonItem()
        addListBarButtonItem()
        
        viewModel.loadTasteCategories()
        viewModel.loadTitle()
        
        subscribe(tasteCategoriesPublisherPublisher: viewModel.tasteCategoriesPublisher)
        subscribe(dishNamePublisher: viewModel.dishNamePublisher)
        
        if let navigationController {
            navigationController.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.black]
        }
    }
    
    static func create(with viewModel: TasteListViewModel) -> TasteListViewController {
        let viewController = TasteListViewController()
        viewController.viewModel = viewModel
        return viewController
    }
    
    private func subscribe(dishNamePublisher: AnyPublisher<String, Never>) {
        dishNamePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] name in
                self?.title = name
            }
            .store(in: &cancellables)
    }
    
    private func subscribe(tasteCategoriesPublisherPublisher: AnyPublisher<[TasteCategory], Never>) {
        tasteCategoriesPublisherPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] tasteCategories in
                for index in 0..<tasteCategories.count {
                    let categoryName = tasteCategories[index].title
                    let categoryButton = TasteCategoryButton(tasteCategoryName: categoryName)
                    self?.tasteListStackView.addArrangedSubview(categoryButton)
                    
                    for tasteIndex in 0..<tasteCategories[index].tastes.count {
                        let onOffButton = OnOffButton(tasteTitle: tasteCategories[index].tastes[tasteIndex])
                        let action = UIAction { _ in
                            onOffButton.toggle()
                            if onOffButton.isSelected {
                                self?.viewModel.didSelectTaste(at: index, at: tasteIndex)
                            } else {
                                self?.viewModel.didDeselectTaste(at: index, at: tasteIndex)
                            }
                        }
                        onOffButton.addAction(action, for: .touchUpInside)
                        self?.tasteListStackView.addArrangedSubview(onOffButton)
                    }
                }
            }
            .store(in: &cancellables)
    }
    
}

extension TasteListViewController {
    private func addBarButtonItem() {
        let barButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(didPressedAddButon))
        navigationItem.rightBarButtonItems = [barButtonItem]
    }
    
    @objc private func didPressedAddButon(_ sender: UIBarButtonItem) {
        let alertController = UIAlertController(title: "완료", message: nil, preferredStyle: .alert)

        let cancelAction = UIAlertAction(title: "취소", style: .destructive, handler: nil)
        alertController.addAction(cancelAction)
        
        let confirmAction = UIAlertAction(title: "저장", style: .default) { _ in
            self.viewModel.didSaveDish()
            self.navigationController?.popViewController(animated: true)
        }
        alertController.addAction(confirmAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    private func addListBarButtonItem() {
        let barButtonItem = UIBarButtonItem(image: UIImage(systemName: "list.bullet"), style: .plain, target: self, action: nil)
        
        var actions: [UIAction] = []
        
        for i in 0..<Constants.tasteCategories.count {
            let action = UIAction(title: Constants.tasteCategories[i].title, handler: { _ in
                let position = self.generateScrollPosition(at: i)
                self.containerScrollView.setContentOffset(.init(x: i, y: position), animated: true)
            })
            actions.append(action)
        }
        
        let menuButton = UIMenu(title: "카테고리", children: actions)
        
        barButtonItem.menu = menuButton
        
        navigationItem.rightBarButtonItems?.append(barButtonItem)
    }
    
    private func generateScrollPosition(at index: Int) -> Int {
        var position: Int = 0
        for i in 0..<index {
            position += Constants.tasteCategories[i].tastes.count * 80
        }
        
        position += index * 80
        
        return position
    }
}

extension TasteListViewController {
    private func addSubviews() {
        view.addSubview(containerScrollView)
        containerScrollView.addSubview(containerView)
        containerView.addSubview(tasteListStackView)
    }
    
    private func adjustLayoutOf(containerScrollView: UIScrollView) {
        containerScrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        containerScrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        containerScrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
        containerScrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
    }
    
    private func adjustLayoutOf(containerView: UIView) {
        let frameLayout = containerScrollView.frameLayoutGuide
        let contentLayout = containerScrollView.contentLayoutGuide
        
        containerView.leadingAnchor.constraint(equalTo: contentLayout.leadingAnchor).isActive = true
        containerView.topAnchor.constraint(equalTo: contentLayout.topAnchor).isActive = true
        containerView.trailingAnchor.constraint(equalTo: contentLayout.trailingAnchor).isActive = true
        containerView.bottomAnchor.constraint(equalTo: contentLayout.bottomAnchor).isActive = true
        
        containerView.leadingAnchor.constraint(equalTo: frameLayout.leadingAnchor).isActive = true
        containerView.trailingAnchor.constraint(equalTo: frameLayout.trailingAnchor).isActive = true
    }
    
    private func adjustLayoutOf(tasteListStackView: UIStackView) {
        tasteListStackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor).isActive = true
        tasteListStackView.topAnchor.constraint(equalTo: containerView.topAnchor).isActive = true
        tasteListStackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor).isActive = true
        tasteListStackView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor).isActive = true
    }
}
