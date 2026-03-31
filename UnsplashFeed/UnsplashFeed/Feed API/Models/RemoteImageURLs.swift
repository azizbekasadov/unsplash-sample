//
//  RemoteImageURLs.swift
//  UnsplashFeed
//
//  Created by Azizbek Asadov on 31.03.2026.
//

import Foundation

struct RemoteImageURLs: Decodable, Equatable, Hashable {
    let raw: URL
    let full: URL
    let regular: URL
    let small: URL
    let thumb: URL
}
