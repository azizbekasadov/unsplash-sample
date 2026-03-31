//
//  RemotePhotoLinks.swift
//  UnsplashFeed
//
//  Created by Azizbek Asadov on 31.03.2026.
//

import Foundation

struct RemotePhotoLinks: Decodable, Equatable, Hashable {
    let html: URL
    let download: URL
    let downloadLocation: URL
    
    enum CodingKeys: String, CodingKey {
        case html
        case download
        case downloadLocation = "download_location"
    }
}
