//
//  SwitchSettingView.swift
//  Reviewer
//
//  Created by Horus on 4/19/24.
//

import UIKit

final class SwitchSettingView: UIView {
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let settingSwitch: UISwitch = {
        let settingSwitch = UISwitch()
        settingSwitch.translatesAutoresizingMaskIntoConstraints = false
        return settingSwitch
    }()
    
    init(title: String, frame: CGRect) {
        super.init(frame: frame)
        self.titleLabel.text = title
        addSubviews()
        adjustLayoutOf(titleLabel: titleLabel)
        adjustLayoutOf(settingSwitch: settingSwitch)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func addSettingSwitch(target: SettingsViewController, action: Selector, for event: UIControl.Event) {
        settingSwitch.addTarget(target, action: action, for: event)
    }
    
    func setSettingSwitch(to value: Bool) {
        settingSwitch.isOn = !value
    }
    
    private func addSubviews() {
        addSubview(titleLabel)
        addSubview(settingSwitch)
    }
    
    private func adjustLayoutOf(titleLabel: UILabel) {
        titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 15).isActive = true
        titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
    }
    
    private func adjustLayoutOf(settingSwitch: UISwitch) {
        settingSwitch.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -15).isActive = true
        settingSwitch.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
    }
    
}
