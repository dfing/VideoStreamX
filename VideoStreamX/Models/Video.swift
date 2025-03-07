//
//  Video.swift
//  VideoStreamX
//
//  Created by kaylla on 2025/3/6.
//

struct Video: Codable {
    let id: String
    let title: String
    let description: String
    let thumbnailURL: String
    let videoURL: String
    let duration: Int
    let author: String
}
