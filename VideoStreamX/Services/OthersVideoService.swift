//
//  OthersVideoService.swift
//  VideoStreamX
//
//  Created by kaylla on 2025/3/11.
//

import Combine
import Foundation

struct OtherVideo: Codable {
    let videos: [OVideo]
    enum CodingKeys: String, CodingKey {
        case videos = "content"
    }
}

class OthersVideoService: VideoService {
    typealias ModelType = VideoData
    typealias CodableType = OVideo
    private var videos: [OVideo] = []
    private var mappedVideos: [VideoData] = []
    private let jsonFileName = "other-video-data.json"

    func fetchVideos() -> AnyPublisher<[VideoData], Error> {
        if !videos.isEmpty {
            return Just(mappedVideos)
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }

        return loadVideosFromJSON()
            .map { [weak self] videos -> [VideoData] in
                // Cache the loaded videos for future use
                self?.videos = videos
                let mappedVideos = self?.mappingToModel(videos) ?? []
                self?.mappedVideos = mappedVideos
                return mappedVideos
            }
            .eraseToAnyPublisher()
    }

    private func loadVideosFromJSON() -> AnyPublisher<[OVideo], Error> {
        return Future<[OVideo], Error> { promise in
            DispatchQueue.global().async {
                do {
                    // Read the JSON file
                    let data = try Data(contentsOf: Bundle.main.url(forResource: self.jsonFileName, withExtension: nil)!)
                    let videoData = try JSONDecoder().decode(OtherVideo.self, from: data)

                    // Return the decoded videos on the main thread
                    DispatchQueue.main.async {
                        promise(.success(videoData.videos))
                    }
                } catch {
                    promise(.failure(error))
                }
            }
        }
        .eraseToAnyPublisher()
    }

}
