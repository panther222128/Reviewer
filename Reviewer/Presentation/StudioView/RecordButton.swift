//
//  RecordButton.swift
//  Reviewer
//
//  Created by Horus on 4/20/24.
//

import UIKit

final class RecordButton: UIButton {
    
    override var isSelected: Bool {
        didSet {
            let symbolConfiguration = UIImage.SymbolConfiguration(pointSize: 64, weight: .bold, scale: .default)
            selectImageView.image = isSelected ? UIImage(systemName: "record.circle.fill", withConfiguration: symbolConfiguration) : UIImage(systemName: "record.circle", withConfiguration: symbolConfiguration)
        }
    }
    
    private let selectImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    init() {
        super.init(frame: .zero)
        
        addSubviews()
        adjustLayoutOf(selectImageView: selectImageView)
        heightAnchor.constraint(equalToConstant: 80).isActive = true
        let symbolConfiguration = UIImage.SymbolConfiguration(pointSize: 64, weight: .bold, scale: .default)
        selectImageView.image = UIImage(systemName: "record.circle", withConfiguration: symbolConfiguration)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func toggle() {
        isSelected = isSelected ? false : true
    }
    
    private func addSubviews() {
        addSubview(selectImageView)
    }
    
    private func adjustLayoutOf(selectImageView: UIImageView) {
        selectImageView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        selectImageView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
    }
    
}
