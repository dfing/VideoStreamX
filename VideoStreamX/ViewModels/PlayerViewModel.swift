//
//  PlayerViewModel.swift
//  VideoStreamX
//
//  Created by kaylla on 2025/3/6.
//

import Combine
import AVFoundation

class PlayerViewModel {
    private var cancellables = Set<AnyCancellable>()

    @Published private(set) var currentVideo: Video?
    @Published var showControls: Bool = false
    @Published private(set) var isPlaying: Bool = false
    @Published private(set) var isLoading: Bool = false
    @Published private(set) var isPlayReady: Bool = false
    @Published private(set) var isPlayEnd: Bool = false
    @Published private(set) var errorMessage: String? = nil
    @Published private(set) var currentTime: Double = 0
    @Published private(set) var duration: Double = 0
    @Published private(set) var bufferedTime: Double = 0
    @Published var isSliderDragging: Bool = false

    private(set) var player: AVPlayer?
    private var playerItem: AVPlayerItem?
    private var timeObserver: Any?

    init() {
    }

    deinit {
        removeTimeObserver()
    }

    func loadVideo(_ video: Video) {
        self.currentVideo = video
        self.isLoading = true
        self.isPlayReady = false

        guard let videoURL = URL(string: video.videoURL) else {
            self.errorMessage = "Invalid video URL"
            self.isLoading = false
            return
        }

        playerItem = AVPlayerItem(url: videoURL)
        if player == nil {
            player = AVPlayer(playerItem: playerItem!)
        } else {
            player?.replaceCurrentItem(with: playerItem!)
        }

        setupTimeObserver()
        observePlayerItem()
    }

    // MARK: - Player Methods
    func toggleControls() {
        showControls.toggle()
    }

    func play() {
        guard isPlayReady else { return }
        if isPlayEnd {
            player?.seek(to: .zero)
            isPlayEnd = false
        }

        player?.play()
        isPlaying = true
    }

    func pause() {
        guard isPlayReady else { return }
        player?.pause()
        isPlaying = false
    }

    func seek(to time: Double) {
        guard isPlayReady else { return }
        player?.seek(to: CMTime(seconds: time, preferredTimescale: 1),
                     toleranceBefore: .zero,
                     toleranceAfter: .zero,
                     completionHandler: { _ in
             self.isSliderDragging = false
        })
        isPlayEnd = false
    }

    func skipForward(seconds: Double = 10) {
        let newTime = min(currentTime + seconds, duration)
        seek(to: newTime)
    }
    
    func skipBackward(seconds: Double = 10) {
        let newTime = max(currentTime - seconds, 0)
        seek(to: newTime)
    }

    // MARK: - Private Methods
    private func observePlayerItem() {
        NotificationCenter.default.publisher(for: .AVPlayerItemDidPlayToEndTime, object: playerItem)
            .sink { [weak self] _ in
                self?.isPlaying = false
                self?.isPlayEnd = true
            }
            .store(in: &cancellables)

        playerItem?.publisher(for: \.status)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] status in
                switch status {
                case .readyToPlay:
                    self?.isLoading = false
                    self?.isPlayReady = true
                    self?.duration = self?.playerItem?.duration.seconds ?? 0

                case .failed:
                    self?.isLoading = false
                    self?.isPlayReady = false
                    self?.errorMessage = self?.playerItem?.error?.localizedDescription ?? "Failed to load video"
                default:
                    break
                }
            }
            .store(in: &cancellables)
    }

    private func setupTimeObserver() {
        removeTimeObserver()

        let interval = CMTime(seconds: 0.5, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        timeObserver = player?.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] time in
            self?.currentTime = time.seconds

            // Update buffered time
            if let playerItem = self?.playerItem,
               let timeRanges = playerItem.loadedTimeRanges.first?.timeRangeValue {
                let bufferedTime = timeRanges.start.seconds + timeRanges.duration.seconds
                self?.bufferedTime = bufferedTime
            }
        }
    }

    private func removeTimeObserver() {
        if let timeObserver = timeObserver, let player = player {
            player.removeTimeObserver(timeObserver)
            self.timeObserver = nil
        }
    }
}
