//
//  InformationListItemCell.swift
//  Shari
//
//  Created by Horus on 6/22/24.
//

import UIKit

final class InformationListItemCell: UITableViewCell {
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: "InformationListItemCellID")
        addSubviews()
        adjustLayoutOf(titleLabel: titleLabel)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func apply(viewModel: InformationListItemViewModel) {
        titleLabel.text = viewModel.title
    }
    
}

extension InformationListItemCell {
    private func addSubviews() {
        addSubview(titleLabel)
    }
    
    private func adjustLayoutOf(titleLabel: UILabel) {
        titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12).isActive = true
    }
}
