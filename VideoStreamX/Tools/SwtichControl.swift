//
//  SwtichControl.swift
//  VideoStreamX
//
//  Created by kaylla on 2025/3/7.
//
import UIKit

class SwtichControl: UIView {
    var title: String?
    var `default`: Bool
    var switchToggled: ((Bool) -> Void)?
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = title
        label.textColor = .white
        label.font = .systemFont(ofSize: 16, weight: .medium)
        return label
    }()
    private let toggleSwitch: UISwitch = {
        let toggleSwitch = UISwitch()
        toggleSwitch.onTintColor = .accent
        toggleSwitch.addTarget(self, action: #selector(switchValueChanged), for: .valueChanged)
        return toggleSwitch
    }()

    init(title: String?, `default`: Bool, switchToggled: ((Bool) -> Void)?) {
        self.title = title
        self.`default` = `default`
        self.switchToggled = switchToggled
        super.init(frame: .zero)
        setup()
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setup() {
        toggleSwitch.isOn = `default`
    }

    private func setupUI() {
        addSubview(toggleSwitch)
        toggleSwitch.snp.makeConstraints({
            $0.width.equalTo(60)
            $0.height.equalTo(40)
            $0.top.equalToSuperview()
            $0.bottom.equalToSuperview()
            $0.trailing.equalToSuperview()
        })

        if let _ = title {
            addSubview(titleLabel)
            titleLabel.snp.makeConstraints({
                $0.centerY.equalTo(toggleSwitch)
                $0.leading.equalToSuperview()
            })
        }
    }

    @objc
    private func switchValueChanged() {
        switchToggled?(toggleSwitch.isOn)
    }
}
