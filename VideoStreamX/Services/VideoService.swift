//
//  VideoService.swift
//  VideoStreamX
//
//  Created by kaylla on 2025/3/6.
//

import Combine

protocol VideoService {
    associatedtype ModelType: Codable
    func fetchVideos() -> AnyPublisher<[ModelType], Error>
}

class AnyVideoService<T: Codable>: VideoService {
    private let _fetchVideos: () -> AnyPublisher<[T], Error>

    init<V: VideoService>(_ service: V) where V.ModelType == T {
        self._fetchVideos = service.fetchVideos
    }

    func fetchVideos() -> AnyPublisher<[T], Error> {
        return _fetchVideos()
    }
}


