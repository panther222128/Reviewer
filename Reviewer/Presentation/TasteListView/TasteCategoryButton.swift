//
//  TasteTitleButton.swift
//  Reviewer
//
//  Created by Horus on 4/25/24.
//

import UIKit

final class TasteCategoryButton: UIButton {
    
    private let tasteCategoryLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .black
        return label
    }()
    
    init(tasteCategoryName: String) {
        super.init(frame: .zero)
        tasteCategoryLabel.text = tasteCategoryName
        
        addSubviews()
        adjustLayoutOf(tasteCategoryLabel: tasteCategoryLabel)
        heightAnchor.constraint(equalToConstant: 80).isActive = true
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    private func addSubviews() {
        addSubview(tasteCategoryLabel)
    }
    
    private func adjustLayoutOf(tasteCategoryLabel: UILabel) {
        tasteCategoryLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 15).isActive = true
        tasteCategoryLabel.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
    }
    
}
