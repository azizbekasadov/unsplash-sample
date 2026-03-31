//
//  FeedItem.swift
//  UnsplashFeed
//
//  Created by Azizbek Asadov on 31.03.2026.
//

import Foundation

public struct FeedImage: Equatable, Hashable {
    public let id: String
    public let description: String?
    public let altDescription: String?
    public let createdAt: Date
    public let width: Int
    public let height: Int
    public let colorHex: String?
    public let blurHash: String?
    public let urls: ImageURLs
    public let links: PhotoLinks
    public let author: AuthorSummary
    
    public init(
        id: String,
        description: String?,
        altDescription: String?,
        createdAt: Date,
        width: Int,
        height: Int,
        colorHex: String?,
        blurHash: String?,
        urls: ImageURLs,
        links: PhotoLinks,
        author: AuthorSummary
    ) {
        self.id = id
        self.description = description
        self.altDescription = altDescription
        self.createdAt = createdAt
        self.width = width
        self.height = height
        self.colorHex = colorHex
        self.blurHash = blurHash
        self.urls = urls
        self.links = links
        self.author = author
    }
}
