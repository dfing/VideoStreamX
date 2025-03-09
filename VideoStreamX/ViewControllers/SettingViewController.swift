//
//  SettingViewController.swift
//  VideoStreamX
//
//  Created by kaylla on 2025/3/7.
//

import UIKit
import Combine

class SettingViewController: UIViewController {

    private lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 20
        return stackView
    }()
    private lazy var closeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "xmark"), for: .normal)
        button.tintColor = .white
        button.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
        return button
    }()
    private lazy var descLabel: UILabel = {
        let label = UILabel()
        label.text = "These settings will apply to playback of all video."
        label.textColor = .systemGray
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.numberOfLines = 0
        return label
    }()

    private var dismissHandler: (() -> Void)?
    private var userSettings = UserSettings.shared

    init(dismissHandler: (() -> Void)? = nil) {
        self.dismissHandler = dismissHandler
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    private func setupUI() {
        view.backgroundColor = .black.withAlphaComponent(0.9)

        let div = UIView()
        div.backgroundColor = .systemGray5

        view.addSubview(closeButton)
        view.addSubview(stackView)
        view.addSubview(div)
        view.addSubview(descLabel)

        closeButton.snp.makeConstraints ({
            $0.top.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().offset(-20)
            $0.width.height.equalTo(40)
        })
        stackView.snp.makeConstraints ({
            $0.top.equalTo(closeButton.snp.bottom).offset(20)
            $0.leading.trailing.equalToSuperview().inset(20)
        })
        div.snp.makeConstraints ({
            $0.height.equalTo(1)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.top.equalTo(stackView.snp.bottom).offset(20)
        })
        descLabel.snp.makeConstraints ({
            $0.top.equalTo(div.snp.bottom).offset(20)
            $0.leading.trailing.equalToSuperview().inset(20)
        })

        let options = [("0.5x", 0.5),
                       ("0.75x", 0.75),
                       ("1x", 1.0),
                       ("1.25x", 1.25),
                       ("1.5x", 1.5)]
        let currentSpeed = userSettings.playbackSpeed
        let defaultIndex = options.firstIndex(where: { abs(Float($0.1) - currentSpeed) < 0.01 }) ?? 2
        let segmentControl = SegmentControl(title: "Speed", options: options,
                                            default: defaultIndex) { [weak self] option in
            let valueFloat = Float(option.value as? Double ?? 1.0)
            self?.userSettings.playbackSpeed = valueFloat
        }

        let autoPlaySwitchControl = SwtichControl(title: "Auto Play",
                                                  default: userSettings.autoPlay, switchToggled: { [weak self] isOn in
            self?.userSettings.autoPlay = isOn
        })

        let autoHideSwitchControl = SwtichControl(title: "Auto Hide Controls",
                                                  default: userSettings.autoHideControls, switchToggled: { [weak self] isOn in
            self?.userSettings.autoHideControls = isOn
        })

        stackView.addArrangedSubview(segmentControl)
        stackView.addArrangedSubview(autoPlaySwitchControl)
        stackView.addArrangedSubview(autoHideSwitchControl)
    }

    @objc
    private func closeButtonTapped() {
        if dismissHandler != nil {
            dismissHandler?()
        } else {
            dismiss(animated: true)
        }
    }
}

