//
//  RemoteProfileImageURLs.swift
//  UnsplashFeed
//
//  Created by Azizbek Asadov on 31.03.2026.
//

import Foundation

struct RemoteProfileImageURLs: Decodable, Equatable, Hashable {
    let small: URL?
    let medium: URL?
    let large: URL?
}
