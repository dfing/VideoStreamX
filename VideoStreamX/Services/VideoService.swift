//
//  VideoService.swift
//  VideoStreamX
//
//  Created by kaylla on 2025/3/6.
//

import Combine

protocol VideoService {
    associatedtype ModelType: VideoDataProtocol
    associatedtype CodableType: Codable & VideoDataProtocol
    func fetchVideos() -> AnyPublisher<[VideoData], Error>
    func mappingToModel(_ data: [CodableType]) -> [VideoData]
}

extension VideoService {
    func mappingToModel(_ data: [CodableType]) -> [VideoData] {
        return data.compactMap { video -> VideoData? in
            // Skip any items with empty required fields
            guard !video.id.isEmpty,
                  !video.title.isEmpty,
                  !video.videoURL.isEmpty else {
                return nil
            }

            return VideoData(
                id: video.id,
                title: video.title,
                description: video.description,
                thumbnailURL: video.thumbnailURL,
                videoURL: video.videoURL,
                duration: video.duration,
                author: video.author
            )
        }
    }
}

//class AnyVideoService<T: VideoDataProtocol>: VideoService {
//    private let _fetchVideos: () -> AnyPublisher<[T], Error>
//
//    init<V: VideoService>(_ service: V) where V.ModelType == T {
//        self._fetchVideos = service.fetchVideos
//    }
//
//    func fetchVideos() -> AnyPublisher<[T], Error> {
//        return _fetchVideos()
//    }
//}


