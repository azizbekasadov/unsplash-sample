//
//  RemoteFeedImage.swift
//  UnsplashFeed
//
//  Created by Azizbek Asadov on 31.03.2026.
//

import Foundation

struct RemoteFeedImage: Decodable, Equatable, Hashable {
    let id: String
    let description: String?
    let altDescription: String?
    let createdAt: Date
    let width: Int
    let height: Int
    let colorHex: String?
    let blurHash: String?
    let urls: RemoteImageURLs
    let links: RemotePhotoLinks
    let author: RemoteAuthorSummary
    
    enum CodingKeys: String, CodingKey {
        case id
        case description
        case altDescription = "alt_description"
        case createdAt = "created_at"
        case width
        case height
        case colorHex = "color"
        case blurHash = "blur_hash"
        case urls
        case links
        case author = "user"
    }
}
