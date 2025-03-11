//
//  GVideo.swift
//  VideoStreamX
//
//  Created by kaylla on 2025/3/6.
//

struct GVideo: Codable, VideoDataProtocol {
    let id: String
    var title: String
    var description: String
    var thumbnailURL: String
    var videoURL: String
    var duration: Int
    var author: String
}
