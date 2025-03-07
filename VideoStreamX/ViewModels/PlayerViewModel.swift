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
    @Published private(set) var showControls: Bool = false
    @Published private(set) var isAllSet: Bool = false
    @Published private(set) var isPlaying: Bool = false
    @Published private(set) var isLoading: Bool = false
    @Published private(set) var errorMessage: String? = nil
    @Published private(set) var currentTime: Double = 0
    @Published private(set) var duration: Double = 0

    private(set) var player: AVPlayer?
    private var playerItem: AVPlayerItem?

    init() {
    }

    func loadVideo(_ video: Video) {
        self.currentVideo = video
        self.isLoading = true
        self.isAllSet = false

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

        isLoading = false
        isAllSet = true
    }

    // MARK: - Player Methods
    func toggleControls() {
        showControls.toggle()
    }

    func play() {
        guard isAllSet else { return }
        player?.play()
        isPlaying = true
    }

    func pause() {
        guard isAllSet else { return }
        player?.pause()
        isPlaying = false
    }

    func seek(to time: Double) {
        guard isAllSet else { return }
        player?.seek(to: CMTime(seconds: time, preferredTimescale: 1))
    }

    // MARK: - Private Methods
}
