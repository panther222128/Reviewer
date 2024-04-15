//
//  ReviewDetailDishItemCell.swift
//  Reviewer
//
//  Created by Horus on 4/14/24.
//

import UIKit

final class RestaurantDishListItemCell: UITableViewCell {
    
    private let dishNameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .black
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: "ReviewDetailDishItemCellID")
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func apply(viewModel: RestaurantDishListItemViewModel) {
        dishNameLabel.text = viewModel.name
    }
    
}
