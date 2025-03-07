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

    private var controlsHideWorkItem: DispatchWorkItem?

    init(video: Video) {
        self.viewModel = PlayerViewModel()
        super.init(nibName: nil, bundle: nil)
        self.viewModel.loadVideo(video)
    }

    deinit {
        controlsHideWorkItem?.cancel()
        controlsHideWorkItem = nil
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
        updateCurrentTimeDisplay()
    }

    // MARK: - Private Methods
    private func setupUI() {
        view.backgroundColor = .systemBackground

        view.addSubview(playerView)
        playerView.layer.addSublayer(playerLayer)

        playerView.addSubview(controlView)
        controlView.addSubview(titleLabel)
        controlView.addSubview(playButton)
        controlView.addSubview(rewindButton)
        controlView.addSubview(forwardButton)
        controlView.addSubview(timeSlider)
        controlView.addSubview(closeButton)
        controlView.addSubview(settingButton)
        controlView.addSubview(currentTimeLabel)
        controlView.addSubview(displayTimeLabel)

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
            $0.leading.equalToSuperview().offset(40)
            $0.width.equalToSuperview().multipliedBy(0.6)
        })

        closeButton.snp.makeConstraints({
            $0.top.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().offset(-20)
            $0.width.height.equalTo(40)
        })
        settingButton.snp.makeConstraints({
            $0.top.equalToSuperview().offset(20)
            $0.trailing.equalTo(closeButton.snp.leading).offset(-10)
            $0.width.height.equalTo(40)
        })
        playButton.snp.makeConstraints({
            $0.center.equalToSuperview()
            $0.width.height.equalTo(60)
        })
        rewindButton.snp.makeConstraints({
            $0.centerY.equalTo(playButton)
            $0.trailing.equalTo(playButton.snp.leading).offset(-70)
            $0.size.equalTo(playButton)
        })
        forwardButton.snp.makeConstraints({
            $0.centerY.equalTo(playButton)
            $0.leading.equalTo(playButton.snp.trailing).offset(70)
            $0.size.equalTo(playButton)
        })
        timeSlider.snp.makeConstraints({
            $0.leading.equalToSuperview().offset(40)
            $0.bottom.equalToSuperview().offset(-50)
            $0.trailing.equalTo(displayTimeLabel.snp.leading).offset(-20)
        })
        displayTimeLabel.snp.makeConstraints({
            $0.trailing.equalToSuperview().offset(-40)
            $0.centerY.equalTo(timeSlider)
        })
        currentTimeLabel.snp.makeConstraints({
            $0.bottom.equalTo(timeSlider.snp.top).offset(-5)
            $0.centerX.equalTo(timeSlider.snp.leading)
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

        viewModel.$isPlayReady
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isReady in
                if isReady {
                    self?.viewModel.play()
                }
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
                self?.updateTimeDisplay()
            }
            .store(in: &cancellable)

        viewModel.$duration
            .receive(on: DispatchQueue.main)
            .sink { [weak self] duration in
                self?.updateTimeDisplay()
            }
            .store(in: &cancellable)
    }

    // MARK: - Actions
    private func showErrorMessage(_ msg: String?) {
        let alert = UIAlertController(title: "Error", message: msg, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    private func showSetting() {
        let settingVC = SettingViewController { [weak self] in
            // Close setting
            guard let self = self else { return }
            guard let settingView = self.view.viewWithTag(919),
                  let settingVC = self.children.first(where: { $0.view == settingView }) as? SettingViewController else {
                return
            }

            settingVC.willMove(toParent: nil)
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseIn, animations: {
                settingVC.view.frame.origin.x = UIScreen.main.bounds.width
            }, completion: { _ in
                // 移除視圖和子視圖控制器
                settingVC.view.removeFromSuperview()
                settingVC.removeFromParent()
            })
        }
        addChild(settingVC)
        let screenWidth = UIScreen.main.bounds.width
        let panelWidth = screenWidth / 3
        settingVC.view.frame = CGRect(x: screenWidth,
                                      y: 0,
                                      width: panelWidth,
                                      height: view.bounds.height)
        settingVC.view.tag = 919
        view.addSubview(settingVC.view)
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
            settingVC.view.frame.origin.x = screenWidth - panelWidth
        }, completion: { _ in
            settingVC.didMove(toParent: self)
        })
    }

    private func updateTimeDisplay() {
        displayTimeLabel.text = (viewModel.duration - viewModel.currentTime).toTimeString()
        if viewModel.duration > 0 && !viewModel.isSliderDragging {
            currentTimeLabel.text = viewModel.currentTime.toTimeString()
            self.timeSlider.value = Float(viewModel.currentTime / viewModel.duration)
        }
    }
    private func updateCurrentTimeDisplay() {
        let trackRect = timeSlider.trackRect(forBounds: timeSlider.bounds)
        let thumbRect = timeSlider.thumbRect(forBounds: timeSlider.bounds, trackRect: trackRect, value: timeSlider.value)
        // 計算滑塊的中心 X 位置
        let thumbCenterX = thumbRect.midX
        // 更新標籤位置以跟隨滑塊
        currentTimeLabel.snp.updateConstraints { make in
            make.centerX.equalTo(timeSlider.snp.leading).offset(thumbCenterX)
        }
    }

    private func scheduleHideControls() {
        controlsHideWorkItem?.cancel()
        let workItem = DispatchWorkItem { [weak self] in
            self?.viewModel.showControls = false
        }
        controlsHideWorkItem = workItem
        DispatchQueue.main.asyncAfter(deadline: .now() + 3, execute: workItem)
    }

    @objc
    private func playerViewTapped() {
        viewModel.toggleControls()
        if viewModel.showControls {
            scheduleHideControls()
        } else {
            controlsHideWorkItem?.cancel()
        }
    }
    @objc
    private func playButtonTapped() {
        viewModel.isPlaying ? viewModel.pause() : viewModel.play()
        scheduleHideControls()
    }
    @objc
    private func closeButtonTapped() {
        viewModel.pause()
        dismiss(animated: true, completion: nil)
    }
    @objc
    private func rewindButtonTapped() {
        viewModel.skipBackward()
        scheduleHideControls()
    }
    @objc
    private func forwardButtonTapped() {
        viewModel.skipForward()
        scheduleHideControls()
    }
    @objc
    private func sliderValueChanged(_ sender: UISlider) {
        viewModel.isSliderDragging = true
        let newTime = Double(sender.value) * viewModel.duration
        currentTimeLabel.text = newTime.toTimeString()
        controlsHideWorkItem?.cancel()
        UIView.animate(withDuration: 0.1) {
            self.view.layoutIfNeeded()
        }
    }
    @objc
    private func sliderTouchEnded(_ sender: UISlider) {
        let newTime = Double(sender.value) * viewModel.duration
        viewModel.seek(to: newTime)
        scheduleHideControls()
    }
    @objc
    private func settingButtonTapped() {
        showSetting()
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
    private lazy var rewindButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "10.arrow.trianglehead.counterclockwise"), for: .normal)
        button.imageView?.contentMode = .scaleAspectFit
        button.contentHorizontalAlignment = .fill
        button.contentVerticalAlignment = .fill
        button.tintColor = .white
        button.addTarget(self, action: #selector(rewindButtonTapped), for: .touchUpInside)
        return button
    }()

    private lazy var forwardButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "10.arrow.trianglehead.clockwise"), for: .normal)
        button.imageView?.contentMode = .scaleAspectFit
        button.contentHorizontalAlignment = .fill
        button.contentVerticalAlignment = .fill
        button.tintColor = .white
        button.addTarget(self, action: #selector(forwardButtonTapped), for: .touchUpInside)
        return button
    }()
    private lazy var closeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "xmark"), for: .normal)
        button.tintColor = .white
        button.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
        return button
    }()
    private lazy var currentTimeLabel: PaddingLabel = {
        let label = PaddingLabel()
        label.text = "00:00"
        label.textColor = .white
        label.textAlignment = .center
        label.backgroundColor = .black.withAlphaComponent(0.8)
        label.layer.cornerRadius = 4
        label.layer.masksToBounds = true
        label.font = .monospacedDigitSystemFont(ofSize: 12, weight: .regular)
        label.textInsets = UIEdgeInsets(top: 4, left: 10, bottom: 4, right: 10)
        return label
    }()
    private lazy var displayTimeLabel: UILabel = {
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
    private lazy var timeSlider: UISlider = {
        let slider = UISlider()
        slider.minimumTrackTintColor = .systemRed
        slider.maximumTrackTintColor = UIColor.white.withAlphaComponent(0.3)
        slider.thumbTintColor = .white
        slider.addTarget(self, action: #selector(sliderValueChanged(_:)), for: .valueChanged)
        slider.addTarget(self, action: #selector(sliderTouchEnded(_:)), for: [.touchUpInside, .touchUpOutside])
        return slider
    }()
    private lazy var settingButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "gearshape.fill"), for: .normal)
        button.tintColor = .white
        button.addTarget(self, action: #selector(settingButtonTapped), for: .touchUpInside)
        return button
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
