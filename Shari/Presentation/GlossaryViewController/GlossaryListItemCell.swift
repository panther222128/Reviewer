//
//  GlossaryListItemCell.swift
//  Reviewer
//
//  Created by Horus on 4/28/24.
//

import UIKit

final class GlossaryListItemCell: UITableViewCell {
    
    private let glossaryItemLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .black
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: "GlossaryListItemCellID")
        addSubviews()
        adjustLayoutOf(glossaryItemLabel: glossaryItemLabel)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func apply(viewModel: GlossaryListItemViewModel) {
        glossaryItemLabel.text = viewModel.content
    }
    
    private func addSubviews() {
        addSubview(glossaryItemLabel)
    }
    
    private func adjustLayoutOf(glossaryItemLabel: UILabel) {
        glossaryItemLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 15).isActive = true
        glossaryItemLabel.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
    }
    
}
