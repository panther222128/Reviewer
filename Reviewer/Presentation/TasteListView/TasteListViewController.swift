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
        subscribe(restaurantNamePublisher: viewModel.restaurantNamePublisher)
    }
    
    static func create(with viewModel: TasteListViewModel) -> TasteListViewController {
        let viewController = TasteListViewController()
        viewController.viewModel = viewModel
        return viewController
    }
    
    private func subscribe(restaurantNamePublisher: AnyPublisher<String, Never>) {
        restaurantNamePublisher
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

        let confirmAction = UIAlertAction(title: "저장", style: .default) { _ in
            self.viewModel.didSaveDish()
            self.navigationController?.popViewController(animated: true)
        }
        alertController.addAction(confirmAction)
        
        let cancelAction = UIAlertAction(title: "취소", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    private func addListBarButtonItem() {
        let barButtonItem = UIBarButtonItem(image: UIImage(systemName: "list.bullet"), style: .plain, target: self, action: nil)
        
        let menuButton = UIMenu(title: "카테고리", children: [
            UIAction(title: Constants.tasteCategories[0].title, handler: { _ in
                self.containerScrollView.setContentOffset(.init(x: 0, y: -80), animated: true)
            }),
            UIAction(title: Constants.tasteCategories[1].title, handler: { _ in
                let position = self.generateScrollPosition(at: 1)
                self.containerScrollView.setContentOffset(.init(x: 0, y: position), animated: true)
            }),
            UIAction(title: Constants.tasteCategories[2].title, handler: { _ in
                let position = self.generateScrollPosition(at: 2)
                self.containerScrollView.setContentOffset(.init(x: 0, y: position), animated: true)
            }),
            UIAction(title: Constants.tasteCategories[3].title, handler: { _ in
                let position = self.generateScrollPosition(at: 3)
                self.containerScrollView.setContentOffset(.init(x: 0, y: position), animated: true)
            }),
            UIAction(title: Constants.tasteCategories[4].title, handler: { _ in
                let position = self.generateScrollPosition(at: 4)
                self.containerScrollView.setContentOffset(.init(x: 0, y: position), animated: true)
            }),
            UIAction(title: Constants.tasteCategories[5].title, handler: { _ in
                let position = self.generateScrollPosition(at: 5)
                self.containerScrollView.setContentOffset(.init(x: 0, y: position), animated: true)
            }),
            UIAction(title: Constants.tasteCategories[6].title, handler: { _ in
                let position = self.generateScrollPosition(at: 6)
                self.containerScrollView.setContentOffset(.init(x: 0, y: position), animated: true)
            }),
            UIAction(title: Constants.tasteCategories[7].title, handler: { _ in
                let position = self.generateScrollPosition(at: 7)
                self.containerScrollView.setContentOffset(.init(x: 0, y: position), animated: true)
            }),
            UIAction(title: Constants.tasteCategories[8].title, handler: { _ in
                let position = self.generateScrollPosition(at: 8)
                self.containerScrollView.setContentOffset(.init(x: 0, y: position), animated: true)
            }),
            UIAction(title: Constants.tasteCategories[9].title, handler: { _ in
                let position = self.generateScrollPosition(at: 9)
                self.containerScrollView.setContentOffset(.init(x: 0, y: position), animated: true)
            }),
            UIAction(title: Constants.tasteCategories[10].title, handler: { _ in
                let position = self.generateScrollPosition(at: 10)
                self.containerScrollView.setContentOffset(.init(x: 0, y: position), animated: true)
            }),
            UIAction(title: Constants.tasteCategories[11].title, handler: { _ in
                let position = self.generateScrollPosition(at: 11)
                self.containerScrollView.setContentOffset(.init(x: 0, y: position), animated: true)
            }),
            UIAction(title: Constants.tasteCategories[12].title, handler: { _ in
                let position = self.generateScrollPosition(at: 12)
                self.containerScrollView.setContentOffset(.init(x: 0, y: position), animated: true)
            }),
            UIAction(title: Constants.tasteCategories[13].title, handler: { _ in
                let position = self.generateScrollPosition(at: 13)
                self.containerScrollView.setContentOffset(.init(x: 0, y: position), animated: true)
            }),
            UIAction(title: Constants.tasteCategories[14].title, handler: { _ in
                let position = self.generateScrollPosition(at: 14)
                self.containerScrollView.setContentOffset(.init(x: 0, y: position), animated: true)
            }),
            UIAction(title: Constants.tasteCategories[15].title, handler: { _ in
                let position = self.generateScrollPosition(at: 15)
                self.containerScrollView.setContentOffset(.init(x: 0, y: position), animated: true)
            }),
            UIAction(title: Constants.tasteCategories[16].title, handler: { _ in
                let position = self.generateScrollPosition(at: 16)
                self.containerScrollView.setContentOffset(.init(x: 0, y: position), animated: true)
            }),
            UIAction(title: Constants.tasteCategories[17].title, handler: { _ in
                let position = self.generateScrollPosition(at: 17)
                self.containerScrollView.setContentOffset(.init(x: 0, y: position), animated: true)
            })
        ])
        
        barButtonItem.menu = menuButton
        
        navigationItem.rightBarButtonItems?.append(barButtonItem)
    }
    
    private func generateScrollPosition(at index: Int) -> Int {
        var position: Int = 0
        for i in 0..<index {
            position += Constants.tasteCategories[i].tastes.count * 80
        }
        if index > 1 {
            position += (index - 1) * 80
        }
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
        containerScrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        containerScrollView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        containerScrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        containerScrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
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
