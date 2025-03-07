//
//  PlayerViewController.swift
//  VideoStreamX
//
//  Created by kaylla on 2025/3/6.
//

import UIKit
import Combine
import AVFoundation

class PlayerViewController: UIViewController {

    private let viewModel: PlayerViewModel
    private var cancellable = Set<AnyCancellable>()

    init(video: Video) {
        self.viewModel = PlayerViewModel()
        super.init(nibName: nil, bundle: nil)
        self.viewModel.loadVideo(video)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setupUI()
        binding()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.play()
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        viewModel.pause()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        playerLayer.frame = playerView.bounds
    }

    // MARK: - Private Methods
    private func setupUI() {
        view.backgroundColor = .systemBackground

        view.addSubview(playerView)
        playerView.layer.addSublayer(playerLayer)

        playerView.addSubview(controlView)
        controlView.addSubview(titleLabel)
        controlView.addSubview(playButton)
        controlView.addSubview(closeButton)
        controlView.addSubview(currentTimeLabel)
        controlView.addSubview(durationLabel)

        playerView.addSubview(loadingIndicator)

        setupConstraints()
    }

    private func setupConstraints() {
        playerView.snp.makeConstraints({
            $0.edges.equalToSuperview()
        })
        loadingIndicator.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        controlView.snp.makeConstraints({
            $0.edges.equalToSuperview()
        })
        titleLabel.snp.makeConstraints({
            $0.top.equalToSuperview().offset(20)
            $0.leading.equalTo(controlView.safeAreaLayoutGuide.snp.leading).offset(40)
            $0.width.equalToSuperview().multipliedBy(0.6)
        })

        closeButton.snp.makeConstraints({
            $0.top.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().offset(-20)
            $0.width.height.equalTo(40)
        })
        playButton.snp.makeConstraints({
            $0.center.equalToSuperview()
            $0.width.height.equalTo(60)
        })
    }

    private func binding() {
        viewModel.$currentVideo
            .receive(on: DispatchQueue.main)
            .compactMap { $0 }
            .sink { [weak self] video in
                self?.titleLabel.text = video.title
                self?.playerLayer.player = self?.viewModel.player
            }
            .store(in: &cancellable)

        viewModel.$errorMessage
            .receive(on: DispatchQueue.main)
            .compactMap { $0 }
            .sink { [weak self] message in
                self?.showErrorMessage(message)
            }
            .store(in: &cancellable)

        viewModel.$showControls
            .receive(on: DispatchQueue.main)
            .sink { [weak self] show in
                UIView.animate(withDuration: 0.3) {
                    self?.controlView.alpha = show ? 1.0 : 0.0
                }
            }
            .store(in: &cancellable)

        viewModel.$isLoading
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLoading in
                isLoading ? self?.loadingIndicator.startAnimating() : self?.loadingIndicator.stopAnimating()
            }
            .store(in: &cancellable)

        viewModel.$isPlaying
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isPlaying in
                self?.playButton.isHighlighted = isPlaying
            }
            .store(in: &cancellable)

        viewModel.$currentTime
            .receive(on: DispatchQueue.main)
            .sink { [weak self] currentTime in
            }
            .store(in: &cancellable)

        viewModel.$duration
            .receive(on: DispatchQueue.main)
            .sink { [weak self] duration in
            }
            .store(in: &cancellable)
    }

    // MARK: - Actions
    private func showErrorMessage(_ msg: String?) {
        let alert = UIAlertController(title: "Error", message: msg, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    @objc
    private func playerViewTapped() {
        viewModel.toggleControls()
    }
    @objc
    private func playButtonTapped() {
        viewModel.isPlaying ? viewModel.pause() : viewModel.play()
    }
    @objc
    private func closeButtonTapped() {
        viewModel.pause()
        dismiss(animated: true, completion: nil)
    }

    // MARK: - Components
    private lazy var playerView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(playerViewTapped))
        view.addGestureRecognizer(tapGesture)
        return view
    }()
    private lazy var playerLayer: AVPlayerLayer = {
        let layer = AVPlayerLayer()
        layer.videoGravity = .resizeAspect
        return layer
    }()
    private lazy var controlView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        view.alpha = 0.0
        return view
    }()
    private lazy var playButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "play.fill"), for: .normal)
        button.setImage(UIImage(systemName: "pause.fill"), for: .highlighted)
        button.imageView?.contentMode = .scaleAspectFit
        button.contentHorizontalAlignment = .fill
        button.contentVerticalAlignment = .fill
        button.tintColor = .white
        button.addTarget(self, action: #selector(playButtonTapped), for: .touchUpInside)
        return button
    }()
    private lazy var closeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "xmark"), for: .normal)
        button.tintColor = .white
        button.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
        return button
    }()
    private lazy var currentTimeLabel: UILabel = {
        let label = UILabel()
        label.text = "00:00"
        label.textColor = .white
        label.font = .monospacedDigitSystemFont(ofSize: 12, weight: .regular)
        return label
    }()
    private lazy var durationLabel: UILabel = {
        let label = UILabel()
        label.text = "00:00"
        label.textColor = .white
        label.font = .monospacedDigitSystemFont(ofSize: 12, weight: .regular)
        return label
    }()
    private lazy var loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.color = .white
        indicator.hidesWhenStopped = true
        return indicator
    }()
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .systemFont(ofSize: 20, weight: .bold)
        return label
    }()
}

extension PlayerViewController {
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .landscape
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }

    override var prefersHomeIndicatorAutoHidden: Bool {
        return true
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)

        coordinator.animate { _ in
            self.playerLayer.frame = self.playerView.bounds
        }
    }
}
