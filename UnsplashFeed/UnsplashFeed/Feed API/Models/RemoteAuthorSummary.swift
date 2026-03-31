//
//  RemoteAuthorSummary.swift
//  UnsplashFeed
//
//  Created by Azizbek Asadov on 31.03.2026.
//

import Foundation

struct RemoteAuthorSummary: Decodable, Equatable, Hashable {
    let id: String
    let username: String
    let name: String
    let portfolioURL: URL?
    let bio: String?
    let location: String?
    let instagramUsername: String?
    let twitterUsername: String?
    let profileImage: RemoteProfileImageURLs?
    let links: RemoteUserLinks?
    
    enum CodingKeys: String, CodingKey {
        case id
        case username
        case name
        case portfolioURL = "portfolio_url"
        case bio
        case location
        case instagramUsername = "instagram_username"
        case twitterUsername = "twitter_username"
        case profileImage = "profile_image"
        case links
    }
}
