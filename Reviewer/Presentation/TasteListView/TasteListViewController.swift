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
        
        viewModel.loadTastes()
        
        subscribe(tastesPublisher: viewModel.tastesPublisher)
    }
    
    static func create(with viewModel: TasteListViewModel) -> TasteListViewController {
        let viewController = TasteListViewController()
        viewController.viewModel = viewModel
        return viewController
    }
    
    private func subscribe(tastesPublisher: AnyPublisher<[String], Never>) {
        tastesPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] tastes in
                for index in 0..<tastes.count {
                    let onOffButton = OnOffButton(tasteTitle: tastes[index])
                    let action = UIAction { _ in
                        onOffButton.toggle()
                        if onOffButton.isSelected {
                            self?.viewModel.didSelectTaste(at: index)
                        } else {
                            self?.viewModel.didDeselectTaste(at: index)
                        }
                    }
                    onOffButton.addAction(action, for: .touchUpInside)
                    self?.tasteListStackView.addArrangedSubview(onOffButton)
                }
            }
            .store(in: &cancellables)
    }
    
}

extension TasteListViewController {
    private func addBarButtonItem() {
        let barButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(didPressedAddButon))
        navigationItem.rightBarButtonItem = barButtonItem
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
