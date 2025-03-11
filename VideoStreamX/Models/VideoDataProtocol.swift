//
//  VideoDataProtocol.swift
//  VideoStreamX
//
//  Created by kaylla on 2025/3/11.
//


protocol VideoDataProtocol {
    var id: String { get }
    var title: String { get }
    var description: String { get }
    var thumbnailURL: String { get }
    var videoURL: String { get }
    var duration: Int { get }
    var author: String { get }
}
