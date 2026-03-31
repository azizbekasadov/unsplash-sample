//
//  AuthorSummary.swift
//  UnsplashFeed
//
//  Created by Azizbek Asadov on 31.03.2026.
//

import Foundation

public struct AuthorSummary: Equatable, Hashable {
    public let id: String
    public let username: String
    public let name: String
    public let portfolioURL: URL?
    public let bio: String?
    public let location: String?
    public let instagramUsername: String?
    public let twitterUsername: String?
    public let profileImage: ProfileImageURLs?
    public let htmlURL: URL?
    
    public init(
        id: String,
        username: String,
        name: String,
        portfolioURL: URL?,
        bio: String?,
        location: String?,
        instagramUsername: String?,
        twitterUsername: String?,
        profileImage: ProfileImageURLs?,
        htmlURL: URL?
    ) {
        self.id = id
        self.username = username
        self.name = name
        self.portfolioURL = portfolioURL
        self.bio = bio
        self.location = location
        self.instagramUsername = instagramUsername
        self.twitterUsername = twitterUsername
        self.profileImage = profileImage
        self.htmlURL = htmlURL
    }
}
