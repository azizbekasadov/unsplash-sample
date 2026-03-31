//
//  RemoteFeedItemMapper.swift
//  UnsplashFeed
//
//  Created by Azizbek Asadov on 31.03.2026.
//

import Foundation

internal enum RemoteFeedItemMapper {
    private static var OK: Int { 200 }
    
    internal static func map(_ data: Data, for response: HTTPURLResponse) -> RemoteFeedLoader.Result {
        guard response.statusCode == OK else {
            return .failure(RemoteFeedLoader.Error.invalidData)
        }
        
        do {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            
            let remoteItems = try decoder.decode([RemoteFeedImage].self, from: data)
            return .success(remoteItems.compactMap(FeedImage.init))
        } catch {
            debugPrint("DECODING ERROR:", error)
            debugPrint("RAW JSON:", String(data: data, encoding: .utf8) ?? "invalid utf8")
            return .failure(RemoteFeedLoader.Error.invalidData)
        }
    }
}

extension FeedImage {
    
    init(_ item: RemoteFeedImage) {
        self.init(
            id: item.id,
            description: item.description,
            altDescription: item.altDescription,
            createdAt: item.createdAt,
            width: item.width,
            height: item.height,
            colorHex: item.colorHex,
            blurHash: item.blurHash,
            urls: ImageURLs(item.urls),
            links: PhotoLinks(item.links),
            author: AuthorSummary(item.author)
        )
    }
}

extension ImageURLs {
    init(_ urls: RemoteImageURLs) {
        self.init(
            raw: urls.raw,
            full: urls.full,
            regular: urls.regular,
            small: urls.small,
            thumb: urls.thumb
        )
    }
}

extension PhotoLinks {
    init(_ links: RemotePhotoLinks) {
        self.init(
            html: links.html,
            download: links.download,
            downloadLocation: links.downloadLocation
        )
    }
}

extension AuthorSummary {
    init(_ user: RemoteAuthorSummary) {
        self.init(
            id: user.id,
            username: user.username,
            name: user.name,
            portfolioURL: user.portfolioURL,
            bio: user.bio,
            location: user.location,
            instagramUsername: user.instagramUsername,
            twitterUsername: user.twitterUsername,
            profileImage: user.profileImage.flatMap(ProfileImageURLs.init),
            htmlURL: user.links?.html
        )
    }
}

extension ProfileImageURLs {
    init?(_ image: RemoteProfileImageURLs) {
        guard
            let small = image.small,
            let medium = image.medium,
            let large = image.large
        else {
            return nil
        }

        self.init(
            small: small,
            medium: medium,
            large: large
        )
    }
}
