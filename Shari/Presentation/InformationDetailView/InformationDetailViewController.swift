//
//  InformationDetailViewController.swift
//  Shari
//
//  Created by Horus on 6/22/24.
//

import UIKit
import WebKit

final class InformationDetailViewController: UIViewController {
    
    private let webView: WKWebView = {
        let webView = WKWebView()
        webView.translatesAutoresizingMaskIntoConstraints = false
        return webView
    }()
    
    private var viewModel: InformationDetailViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        addSubviews()
        adjustLayoutOf(webView: webView)
        
        loadWebView()
    }
    
    static func create(with viewModel: InformationDetailViewModel) -> InformationDetailViewController {
        let viewController = InformationDetailViewController()
        viewController.viewModel = viewModel
        return viewController
    }
    
    private func loadWebView() {
        if let url = viewModel.url {
            let urlRequest = URLRequest(url: url)
            webView.load(urlRequest)
        }
    }
    
}

extension InformationDetailViewController {
    private func addSubviews() {
        if let url = viewModel.url {
            view.addSubview(webView)
        }
    }
    
    private func adjustLayoutOf(webView: WKWebView) {
        if let url = viewModel.url {
            webView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
            webView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
            webView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        }
    }
}
