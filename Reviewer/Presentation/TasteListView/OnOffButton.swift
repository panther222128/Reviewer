//
//  OnOffButton.swift
//  Reviewer
//
//  Created by Horus on 4/12/24.
//

import UIKit

final class OnOffButton: UIButton {
    
    override var isSelected: Bool {
        didSet {
            if isSelected {
                selectImageView.image = UIImage(systemName: "circle.circle.fill")
            } else {
                selectImageView.image = UIImage(systemName: "circle")
            }
        }
    }
    
    private let tasteTitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let selectImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    init(tasteTitle: String) {
        super.init(frame: .zero)
        tasteTitleLabel.text = tasteTitle
        
        addSubviews()
        adjustLayoutOf(tasteTitleLabel: tasteTitleLabel)
        adjustLayoutOf(selectImageView: selectImageView)
        heightAnchor.constraint(equalToConstant: 80).isActive = true
        
        selectImageView.image = UIImage(systemName: "circle")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func toggle() {
        if isSelected {
            isSelected = false
        } else {
            isSelected = true
        }
    }
    
    private func addSubviews() {
        addSubview(tasteTitleLabel)
        addSubview(selectImageView)
    }
    
    private func adjustLayoutOf(tasteTitleLabel: UILabel) {
        tasteTitleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 15).isActive = true
        tasteTitleLabel.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
    }
    
    private func adjustLayoutOf(selectImageView: UIImageView) {
        selectImageView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -15).isActive = true
        selectImageView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
    }
    
}
