//
//  DishDetailListItemCell.swift
//  Reviewer
//
//  Created by Jun Ho JANG on 4/15/24.
//

import UIKit

final class DishDetailListItemCell: UITableViewCell {
    
    private let tasteLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .black
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: "DishDetailListItemCellID")
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func apply(viewModel: DishDetailListItemViewModel) {
        tasteLabel.text = viewModel.taste
    }
    
}
