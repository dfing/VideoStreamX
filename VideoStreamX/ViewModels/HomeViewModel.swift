//
//  HomeViewModel.swift
//  VideoStreamX
//
//  Created by kaylla on 2025/3/6.
//

import Combine
import Foundation

class HomeViewModel {
    @Published var videos: [VideoData] = []

    private let service: any VideoService
    private var cancellables = Set<AnyCancellable>()

    init<S: VideoService>(service: S) where S.ModelType == VideoData {
        self.service = service
        fetch()
    }

    private func fetch() {
        service.fetchVideos()
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    print("Error fetching videos: \(error)")
                }
            }, receiveValue: { [weak self] videos in
                self?.videos = videos
            })
            .store(in: &cancellables)
    }
}
