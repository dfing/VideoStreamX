//
//  OVideo.swift
//  VideoStreamX
//
//  Created by kaylla on 2025/3/11.
//

struct OVideo: Codable, VideoDataProtocol {
    let id: String
    var title: String
    var description: String
    var thumbnailURL: String
    var videoURL: String
    var duration: Int
    var author: String

    enum CodingKeys: String, CodingKey {
        case id = "content_id"
        case title = "content_name"
        case description = "content_summary"
        case thumbnailURL = "preview_image"
        case videoURL = "content_url"
        case duration = "play_length"
        case author = "creator"
    }
}
