//
//  SettingsViewController.swift
//  Reviewer
//
//  Created by Horus on 4/11/24.
//

import UIKit

final class SettingsViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
    }
    
    static func create() -> SettingsViewController {
        let viewController = SettingsViewController()
        return viewController
    }
    
}
