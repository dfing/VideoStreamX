//
//  SampleVideoService.swift
//  VideoStreamX
//
//  Created by kaylla on 2025/3/6.
//

import Combine
import Foundation
/**
 Google 提供的開放示範影片
 */

struct VideoData: Codable {
    let videos: [Video]
}

class SampleVideoService: VideoService {
    typealias ModelType = Video
    private var videos: [Video] = []
    private let jsonFileName = "video-data.json"

    func fetchVideos() -> AnyPublisher<[Video], Error> {
        if !videos.isEmpty {
            return Just(videos)
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }

        return loadVideosFromJSON()
            .map { [weak self] videos -> [Video] in
                // Cache the loaded videos for future use
                self?.videos = videos
                return videos
            }
            .eraseToAnyPublisher()
    }

    // MARK: - Private Methods
    private func loadVideosFromJSON() -> AnyPublisher<[Video], Error> {
        return Future<[Video], Error> { promise in
            DispatchQueue.global().async {
                do {
                    // Read the JSON file
                    let data = try Data(contentsOf: Bundle.main.url(forResource: self.jsonFileName, withExtension: nil)!)
                    let videoData = try JSONDecoder().decode(VideoData.self, from: data)

                    // Return the decoded videos on the main thread
                    DispatchQueue.main.async {
                        promise(.success(videoData.videos))
                    }
                } catch {
                    DispatchQueue.main.async {
                        // Create some default sample videos as fallback
                        let fallbackVideos = self.createFallbackVideos()
                        promise(.success(fallbackVideos))
                    }
                }
            }
        }
        .eraseToAnyPublisher()
    }

    private func createFallbackVideos() -> [Video] {
        return [
            Video(id: "v1",
                  title: "大自然風景記錄片：冰川與雨林",
                  description: "這部影片帶您探索地球上最美麗的自然景觀。從壯觀的冰川到神秘的雨林，見證大自然的力量與美麗。",
                  thumbnailURL: "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/images/BigBuckBunny.jpg",
                  videoURL: "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4",
                  duration: 598,
                  author: "自然探索頻道"),
            Video(id: "v2",
                  title: "城市夜景城市夜景縮時攝影",
                  description: "現代大都市的縮時攝影，展現了城市從日落到黎明的變化。燈光、車流與建築共同創造出迷人的城市夜景。",
                  thumbnailURL: "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/images/ElephantsDream.jpg",
                  videoURL: "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4",
                  duration: 435,
                  author: "城市視角工作室"),
            Video(id: "v3",
                  title: "水下世界探索：珊瑚礁生態系統",
                  description: "潛入深海，探索豐富多彩的珊瑚礁生態系統。跟隨專業潛水員的鏡頭，欣賞海洋中最美麗的生物。",
                  thumbnailURL: "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/images/ForBiggerBlazes.jpg",
                  videoURL: "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4",
                  duration: 362,
                  author: "深海探險隊")
        ]
    }
}
