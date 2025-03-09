//
//  SegmentControl.swift
//  VideoStreamX
//
//  Created by kaylla on 2025/3/7.
//

import UIKit

class SegmentControl: UIView {
    typealias Option = (string: String, value: Any)
    var title: String?
    var options: [Option]
    var `default`: Int
    var valueChanged: ((Option) -> Void)?
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = title
        label.textColor = .white
        label.font = .systemFont(ofSize: 16, weight: .medium)
        return label
    }()
    private var segmentControl: UISegmentedControl

    init(title: String?, options: [Option], `default`: Int, valueChanged: ((Option) -> Void)?) {
        self.title = title
        self.options = options
        self.`default` = min(options.count, max(0, `default`))
        self.valueChanged = valueChanged
        self.segmentControl = UISegmentedControl(items: options.map { $0.string })
        super.init(frame: .zero)
        setup()
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setup() {
        segmentControl.selectedSegmentTintColor = .accent
        segmentControl.selectedSegmentIndex = self.default
        segmentControl.addTarget(self, action: #selector(segmentValueChanged(_:)), for: .valueChanged)
    }

    private func setupUI() {
        if let _ = title {
            addSubview(titleLabel)
            titleLabel.snp.makeConstraints({
                $0.top.equalToSuperview()
                $0.leading.trailing.equalToSuperview()
            })
        }

        addSubview(segmentControl)
        segmentControl.snp.makeConstraints({
            if let _ = title {
                $0.top.equalTo(titleLabel.snp.bottom).offset(10)
            } else {
                $0.top.equalToSuperview()
            }
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalToSuperview()
        })
    }

    @objc
    private func segmentValueChanged(_ sender: UISegmentedControl) {
        let selectedOption = options[sender.selectedSegmentIndex]
        valueChanged?(selectedOption)
    }
}
