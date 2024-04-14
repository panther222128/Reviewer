//
//  ReviewListItemCell.swift
//  Reviewer
//
//  Created by Horus on 4/10/24.
//

import UIKit

final class ReviewListItemCell: UITableViewCell {
    
    private let restaurantLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 24)
        return label
    }()
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 16)
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: "ReviewListItemCellID")
        addSubviews()
        adjustLayoutOf(restaurantLabel: restaurantLabel)
        adjustLayoutOf(dateLabel: dateLabel)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func apply(reviewListItemViewModel: ReviewListItemViewModel) {
        restaurantLabel.text = reviewListItemViewModel.restaurantName
        dateLabel.text = reviewListItemViewModel.date.formatYearMonthDate()
    }
    
}

extension ReviewListItemCell {
    private func addSubviews() {
        addSubview(restaurantLabel)
        addSubview(dateLabel)
    }
    
    private func adjustLayoutOf(restaurantLabel: UILabel) {
        restaurantLabel.topAnchor.constraint(equalTo: topAnchor, constant: 15).isActive = true
        restaurantLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 15).isActive = true
    }
    
    private func adjustLayoutOf(dateLabel: UILabel) {
        dateLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10).isActive = true
        dateLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 15).isActive = true
    }
}
