//
//  HomeViewModel.swift
//  VideoStreamX
//
//  Created by kaylla on 2025/3/6.
//

import Combine
import Foundation

class HomeViewModel {
    @Published var videos: [Video] = []

    private let service: AnyVideoService<Video>
    private var cancellables = Set<AnyCancellable>()

    init<S: VideoService>(service: S) where S.ModelType == Video {
        self.service = AnyVideoService(service)
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

/*
 struct Movie: Codable { /* properties */ }

 class MovieVideoService: VideoServiceBase {
 typealias VideoType = Movie
 func fetchVideos() -> AnyPublisher<[Movie], Error> { /* implementation */ }
 }

 class MovieViewModel {
 private let service: AnyVideoService<Movie>
 init<S: VideoServiceBase>(service: S) where S.VideoType == Movie { /* ... */ }
 }
 */
