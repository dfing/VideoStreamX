//
//  VideoData.swift
//  VideoStreamX
//
//  Created by kaylla on 2025/3/11.
//

struct VideoData: Codable, VideoDataProtocol {
    var id: String
    var title: String
    var description: String
    var thumbnailURL: String
    var videoURL: String
    var duration: Int
    var author: String
}
