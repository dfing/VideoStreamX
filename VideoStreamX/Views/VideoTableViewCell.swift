//
//  VideoTableViewCell.swift
//  VideoStreamX
//
//  Created by kaylla on 2025/3/6.
//

import UIKit
import SDWebImage

class VideoTableViewCell: UITableViewCell {
    static let identifier = "VideoTableViewCell"

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .systemFont(ofSize: 20, weight: .medium)
        label.numberOfLines = 2
        return label
    }()
    private lazy var descLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.numberOfLines = 3
        return label
    }()
    private lazy var thumbnailImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.backgroundColor = .systemGray5
        return imageView
    }()
    private lazy var durationLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13, weight: .regular)
        return label
    }()
    private lazy var authorLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13, weight: .regular)
        return label
    }()

    // MARK: -
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        contentView.addSubview(thumbnailImageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(descLabel)
        contentView.addSubview(durationLabel)
        contentView.addSubview(authorLabel)

        let blur = UIView()
        blur.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        blur.frame = thumbnailImageView.bounds
        blur.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        thumbnailImageView.addSubview(blur)

        thumbnailImageView.snp.makeConstraints({
            $0.edges.equalToSuperview()
            $0.height.equalTo(180)
        })
        titleLabel.snp.makeConstraints({
            $0.leading.trailing.equalToSuperview().inset(10)
            $0.top.equalToSuperview().offset(10)
        })
        descLabel.snp.makeConstraints({
            $0.leading.trailing.equalToSuperview().inset(10)
            $0.top.equalTo(titleLabel.snp.bottom).offset(10)
        })
        durationLabel.snp.makeConstraints({
            $0.trailing.equalToSuperview().inset(10)
            $0.bottom.equalToSuperview().inset(10)
        })
        authorLabel.snp.makeConstraints({
            $0.trailing.equalToSuperview().inset(10)
            $0.bottom.equalTo(durationLabel.snp.top).offset(-5)
        })
    }

    // MARK: -
    func configure(with video: Video) {
        thumbnailImageView.sd_setImage(with: URL(string: video.thumbnailURL))
        titleLabel.text = video.title
        descLabel.text = video.description
        durationLabel.text = video.duration.toTimeString()
        authorLabel.text = video.author
    }
}
